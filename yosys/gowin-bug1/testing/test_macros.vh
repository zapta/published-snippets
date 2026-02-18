// Helper macros for testbenches.

`timescale 1ns / 1ps

// This is a non synthesizable module, include in testbenches only.
`ifdef SYNTHESIS
  `error "This file/header is intended for simulation/testbench only."
`endif


// Skip to the next negative clock edge,
`define CLK @(negedge sys_clk);


// Skip to the N'th next negative clock edge.
`define CLKS(n) repeat (n) @(negedge sys_clk);


// Assertion macro. If using, define a reg named assertion_error
// in your testbench
`define EXPECT_EQ(actual, expected) \
  if ((actual) !== (expected)) begin \
    $display("ERROR at %s:%0d: expected %s = %0b but got %0b", \
             `__FILE__, `__LINE__, `"actual`", expected, actual); \
    assertion_err = 1; \
    if (!`APIO_SIM) $fatal; \
  end



