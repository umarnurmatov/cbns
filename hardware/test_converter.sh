#!/bin/bash

set -e

MODULES="converter_im.v converter_re.v ripple_carry_adder.v full_adder.v converter.v"
TESTBENCH="tb_converter.sv"
BUILD_DIR="build/converter"
DUMP_DIR="dump/converter"
WIDTH=(7 8 9 10)

mkdir -p $BUILD_DIR
mkdir -p $DUMP_DIR

for width in "${WIDTH[@]}"; do
  iverilog -g2012 -DIN_WIDTH=$width -DDUMP_FILE=\"${DUMP_DIR}/dump_${width}.vcd\" -o ${BUILD_DIR}/out_${width}.vvp $MODULES $TESTBENCH
done

for width in "${WIDTH[@]}"; do
  vvp $BUILD_DIR/out_$width.vvp
done
