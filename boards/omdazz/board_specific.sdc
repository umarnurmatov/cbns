create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from RESET                    -to [all_clocks]
set_false_path -from [get_ports {KEY_SW[*]}]  -to [all_clocks]
set_false_path -from [get_ports {PSEUDO_GPIO_USING_SDRAM_PINS[*]}] -to [all_clocks]

set_false_path -from * -to [get_ports {SEG[*]}]
set_false_path -from * -to [get_ports {DIG[*]}]
set_false_path -from * -to [get_ports {PSEUDO_GPIO_USING_SDRAM_PINS[*]}]

