#!/bin/bash -x

# Sample script to demonstrate the problem on Sipeed Tang Nano 9k.

# Stop on first error.
set -e

# Set the Yosys env if needed.
if [ -z "${VIRTUAL_ENV:-}" ]; then
  source /Users/user/.apio/packages/oss-cad-suite/environment
fi

# Prepare an empty output dir
#rm -rf _build/tang9k
#mkdir -p _build/tang9k

rm -f _build/tang9k/hardware.pnr.json
rm -f _build/tang9k/hardware.pnr

# Yosys
#yosys -p "synth_gowin -top main -json _build/tang9k/hardware.json; write_verilog _build/tang9k/yosys-synth.v" -q -DSYNTHESIZE main.v pll.v async_fifo.v

# PNR
nextpnr-himbaechel --device GW1NR-LV9QN88PC6/I5 --json _build/tang9k/hardware.json --write _build/tang9k/hardware.pnr.json --report _build/tang9k/hardware.pnr --vopt family=GW1N-9C --vopt cst=pinout-tang9k.cst -q --seed 1008

# Pack
gowin_pack -d GW1N-9C -o _build/tang9k/hardware.fs _build/tang9k/hardware.pnr.json

# Upload
openFPGALoader -b tangnano9k -f _build/tang9k/hardware.fs
