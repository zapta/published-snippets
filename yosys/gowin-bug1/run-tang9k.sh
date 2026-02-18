#!/bin/bash -x

# Sample script to demonstrate the problem on Sipeed Tang Nano 9k.

# Stop on first error.
set -e

# Set the Yosys env.
source /Users/user/.apio/packages/oss-cad-suite/environment

# Prepare an empty output dir
rm -rf _build/tang9k
mkdir -p _build/tang9k

# Yosys
yosys -p "synth_gowin -top main -json _build/tang9k/hardware.json" -q -DSYNTHESIZE main.v async_fifo/async_fifo.v async_fifo/fifomem.v async_fifo/rptr_empty.v async_fifo/sync_r2w.v async_fifo/sync_w2r.v async_fifo/wptr_full.v testing/test_utils.v

# PNR
nextpnr-himbaechel --device GW1NR-LV9QN88PC6/I5 --json _build/tang9k/hardware.json --write _build/tang9k/hardware.pnr.json --report _build/tang9k/hardware.pnr --vopt family=GW1N-9C --vopt cst=tang9k-pinout.cst -q --seed 1008

# Pack
gowin_pack -d GW1N-9C -o _build/tang9k/hardware.fs _build/tang9k/hardware.pnr.json

# Upload
openFPGALoader -b tangnano9k -f _build/tang9k/hardware.fs
