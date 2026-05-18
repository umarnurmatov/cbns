#!/usr/bin/env bash
set -euo pipefail

# ----------------------------- Configuration ---------------------------------
# Default values
PROJECT_NAME="cbns"
BUILD_DIR="quartus"
TOP_MODULE="top"
FILELIST="fpga_filelist.txt"
PINMAP="$(realpath boards/omdazz/board_specific.qsf)"
SDC="$(realpath boards/omdazz/board_specific.sdc)"
RUN_SYNTHESIS=1
UPLOAD_FPGA=1
QUARTUS_BIN_DIR="bin"

error_exit() {
    echo -e "\033[0;31m[  ERROR]\033[0m $*" >&2
    exit 1
}

info() {
    echo -e "\033[0;32m[   INFO]\033[0m $*"
}

warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $*" >&2
}

# Locate Quartus installation (adapted from your reference script)
setup_quartus_env() {
    if command -v quartus_sh >/dev/null 2>&1; then
        QUARTUS_SH=$(command -v quartus_sh)
        QUARTUS_ROOTDIR=$(dirname "$(dirname "$QUARTUS_SH")")
        info "Using Quartus from PATH: $QUARTUS_ROOTDIR"
        return 0
    fi

# Try common install locations
    local search_dirs=()
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        search_dirs=("$HOME" "/opt" "/tools")
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        search_dirs=("/c" "/d" "/e")
    fi
    for parent in "${search_dirs[@]}"; do
        for sub in "intelFPGA_lite" "intelFPGA" "altera"; do
            if [[ -d "$parent/$sub" ]]; then
                # pick the newest version
                local latest=$(find "$parent/$sub" -maxdepth 1 -type d -name "2*" | sort | tail -1)
                if [[ -n "$latest" && -d "$latest/quartus" ]]; then
                    QUARTUS_ROOTDIR="$latest/quartus"
                    if [[ "$OSTYPE" == "linux-gnu" ]]; then
                        QUARTUS_BIN_DIR="bin"
                    else
                        QUARTUS_BIN_DIR="bin64"
                    fi
                    export PATH="$QUARTUS_ROOTDIR/$QUARTUS_BIN_DIR:$PATH"
                    info "Found Quartus at $QUARTUS_ROOTDIR"
                    return 0
                fi
            fi
        done
    done
    error_exit "Quartus not found. Please source your Quartus setup script or ensure 'quartus_sh' is in PATH."
}

# ---------------------------- Command line parsing ---------------------------
show_help() {
    cat <<EOF
Options:
  --top TOP_MODULE           Name of the top-level design entity
  --filelist FILELIST        Text file listing all source files (one per line)
  --project NAME             Project name (default: same as TOP_MODULE)
  --pinmap FILE              Board-specific pin assignments (will be added to .qsf)
  --sdc FILE                 Timing constraints file
  --help                     Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --top) TOP_MODULE="$2"; shift 2 ;;
        --filelist) FILELIST="$2"; shift 2 ;;
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --pinmap) PINMAP="$2"; shift 2 ;;
        --sdc) SDC="$2"; shift 2 ;;
        --help) show_help; exit 0 ;;
        *) error_exit "Unknown option: $1";;
    esac
done

[[ -z "$TOP_MODULE" ]]               && error_exit "--top is required"
[[ -z "$FILELIST" ]]                 && error_exit "--filelist is required"
[[ ! -f "$FILELIST" ]]               && error_exit "Filelist '$FILELIST' not found"
[[ -n "$PINMAP" && ! -f "$PINMAP" ]] && error_exit "Pinmap '$PINMAP' not found"
[[ -n "$SDC" && ! -f "$SDC" ]]       && error_exit "SDC file '$SDC' not found"

# -------------------------- Generate project files ---------------------------
setup_quartus_env
quartus_sh_exe="quartus_sh"
quartus_pgm_exe="quartus_pgm"

mkdir -p $BUILD_DIR
QPF="$BUILD_DIR/$PROJECT_NAME.qpf"
QSF="$BUILD_DIR/$PROJECT_NAME.qsf"

info "Generating project '$PROJECT_NAME' with top module '$TOP_MODULE'"

cat > "$QPF" <<EOF
PROJECT_REVISION = "$PROJECT_NAME"
EOF

cat > "$QSF" <<EOF
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "$(realpath $BUILD_DIR)"
set_global_assignment -name TOP_LEVEL_ENTITY "$TOP_MODULE"
set_global_assignment -name VERILOG_INPUT_VERSION SystemVerilog_2005
set_instance_assignment -name PRESERVE_REGISTER ON -to "top"
EOF

while IFS= read -r src_file; do
    ext="${src_file##*.}"
    case "$ext" in
        sv|SV) echo "set_global_assignment -name SYSTEMVERILOG_FILE \"$(realpath $src_file)\"" ;;
        *)     echo "set_global_assignment -name VERILOG_FILE \"$(realpath $src_file)\"" ;;
    esac >> "$QSF"
done < "$FILELIST"

if [[ -n "$SDC" ]]; then
    echo "set_global_assignment -name SDC_FILE \"$SDC\"" >> "$QSF"
fi

echo "set_global_assignment -name NUM_PARALLEL_PROCESSORS 8" >> "$QSF"

if [[ -n "$PINMAP" ]]; then
    cat $PINMAP >> $QSF
fi

info "Generated $QPF and $QSF"

# -------------------------- Run synthesis & fitter ---------------------------
if [[ "$RUN_SYNTHESIS" -eq 1 ]]; then
    info "Starting Quartus compilation..."
    log_file="$BUILD_DIR/${PROJECT_NAME}_compile.log"
    if ! "$quartus_sh_exe" --flow compile "$BUILD_DIR/$PROJECT_NAME" > "$log_file" 2>&1; then
        grep -i -A 5 "error" "$log_file" 2>&1 || true
        error_exit "Quartus compilation failed. See $log_file"
    fi
    info "Compilation successful"
fi

# -------------------------- Program FPGA ----------------------
if [[ "$UPLOAD_FPGA" -eq 1 ]]; then
    info "Programming FPGA..."
    # Find programming cable (similar to reference script)
    cable_list=$(mktemp)
    "$quartus_pgm_exe" -l > "$cable_list" 2>/dev/null
    cable_name=$(grep -E '^[0-9]+\)' "$cable_list" | head -1 | sed 's/^[0-9]*) //')
    rm -f "$cable_list"
    if [[ -z "$cable_name" ]]; then
        error_exit "No USB-Blaster cable detected. Check connections and udev rules (Linux) or drivers (Windows)."
    fi
    info "Using cable: $cable_name"

    SOF_FILE="output_files/${PROJECT_NAME}.sof"
    if [[ ! -f "$SOF_FILE" ]]; then
        error_exit "SRAM object file $SOF_FILE not found. Compilation may have failed."
    fi

    # For Cyclone V SoC devices (DE1-SoC / DE10-Nano) the FPGA is at position @2
    if [[ "$DEVICE" =~ ^5C ]]; then
        "$quartus_pgm_exe" --no_banner -c "$cable_name" --mode=jtag -o "P;$SOF_FILE@2"
    else
        "$quartus_pgm_exe" --no_banner -c "$cable_name" --mode=jtag -o "P;$SOF_FILE"
    fi
    info "FPGA configured successfully."
fi

info "All tasks completed."
