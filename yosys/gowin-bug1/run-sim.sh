#!/bin/bash -x

# Sample script to simulate the testbench main_tb.v

# Stop on first error.
set -e

# Set the Yosys env if needed.
if [ -z "${VIRTUAL_ENV:-}" ]; then
  source /Users/user/.apio/packages/oss-cad-suite/environment
fi

# Prepare an empty output dir
rm -rf _build/tang9k
mkdir -p _build/tang9k

# Iverilog
iverilog -g2012 -o _build/tang9k/main_tb.out -DVCD_OUTPUT=_build/tang9k/main_tb -DAPIO_SIM=1 -DINTERACTIVE_SIM -I"/Users/user/.apio/packages/oss-cad-suite/share/yosys/gowin" "/Users/user/.apio/packages/oss-cad-suite/share/yosys/gowin/cells_sim.v" main.v pll.v async_fifo.v main_tb.v

# VVP
vvp _build/tang9k/main_tb.out -dumpfile=_build/tang9k/main_tb.vcd

# GTKwave
gtkwave "--rcvar=splash_disable on" "--rcvar=do_initial_zoom_fit 1" "--rcvar=do_initial_zoom_fit 0" _build/tang9k/main_tb.vcd main_tb.gtkw

