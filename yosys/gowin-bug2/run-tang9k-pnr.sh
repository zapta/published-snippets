#!/bin/bash -x

# Perform she post Yosys build and upload. Allows to use a 
# manually patched _build/tang9k/hardware.json.

# Stop on first error.
set -e

# Set the Yosys env if needed.
if [ -z "${VIRTUAL_ENV:-}" ]; then
  source /Users/user/.apio/packages/oss-cad-suite/environment
fi

rm -f _build/tang9k/hardware.pnr.json
rm -f _build/tang9k/hardware.pnr

# PNR
nextpnr-himbaechel --device GW1NR-LV9QN88PC6/I5 --json _build/tang9k/hardware.json --write _build/tang9k/hardware.pnr.json --report _build/tang9k/hardware.pnr --vopt family=GW1N-9C --vopt cst=pinout-tang9k.cst -q --seed 1008

# Pack
gowin_pack -d GW1N-9C -o _build/tang9k/hardware.fs _build/tang9k/hardware.pnr.json

# Upload
openFPGALoader -b tangnano9k -f _build/tang9k/hardware.fs
