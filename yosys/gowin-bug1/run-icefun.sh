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
yosys -p "synth_ice40 -top main -json _build/icefun/hardware.json" -q -DSYNTHESIZE main.v async_fifo/async_fifo.v async_fifo/fifomem.v async_fifo/rptr_empty.v async_fifo/sync_r2w.v async_fifo/sync_w2r.v async_fifo/wptr_full.v testing/test_utils.v

# PNR
nextpnr-ice40 --hx8k --package cb132 --json _build/icefun/hardware.json --asc _build/icefun/hardware.asc --report _build/icefun/hardware.pnr --pcf icefun-pinout.pcf -q --seed 1008

# Pack
icepack _build/icefun/hardware.asc _build/icefun/hardware.bin

# Upload
icefunprog /dev/cu.usbmodem000000001 _build/icefun/hardware.bin
