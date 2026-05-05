`define MX_CARRY_WIDTH 8

`define ANSI_COLOR_RED "\x1b[31m"
`define ANSI_COLOR_GREEN "\x1b[32m"
`define ANSI_COLOR_YELLOW "\x1b[33m"
`define ANSI_COLOR_RESET "\x1b[0m"

`define YELLOW(str) {`ANSI_COLOR_YELLOW, str, `ANSI_COLOR_RESET}
`define GREEN(str) {`ANSI_COLOR_GREEN, str, `ANSI_COLOR_RESET}
`define RED(str) {`ANSI_COLOR_RED  , str, `ANSI_COLOR_RESET}

