#!/bin/bash

MODULES="converter_im.v converter_re.v ripple_carry_adder.v full_adder.v converter.v"
TESTBENCH="tb.sv"
VVP_OUT="out.vvp"

iverilog -g2012 -o $VVP_OUT $MODULES $TESTBENCH
vvp $VVP_OUT