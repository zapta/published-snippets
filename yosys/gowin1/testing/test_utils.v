// clock_gen.vh
// Reusable 10 MHz clock generator with reset (high for first 3 cycles) and cycle counter
// Include this file in testbenches and instantiate clock_gen_inst as shown below

`timescale 1ns / 1ps

// This is a non synthesizable module, include in testbenches only.
`ifndef SYNTHESIS


module test_clock_gen #(
    parameter int PERIOD = 100,
    parameter int RESET_CLKS = 3
) (
    output reg clk,
    output reg rst,
    output integer cycle_count
);

  initial begin
    clk = 0;
    forever #(PERIOD / 2) clk = ~clk;  // 10 MHz clock
  end

  // Reset is high for the first 
  initial begin
    rst = 1;
    repeat (RESET_CLKS) @(posedge clk);
    #1 rst = 0;
  end

  initial begin
    cycle_count = 0;
  end

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
  end

endmodule


module test_data_stream #(
    parameter integer DATA_WIDTH = 32,
    parameter integer NUM_VALUES = 32,
    parameter integer MAX_ENTRIES = 32,
    parameter [DATA_WIDTH*32-1:0] VALUES = {32{{DATA_WIDTH{1'b0}}}}
) (
    input  wire                  sys_clk,
    input  wire                  sys_reset,
    input  wire                  next_data_req,
    output reg  [DATA_WIDTH-1:0] data_out
);

  generate
    if (NUM_VALUES > MAX_ENTRIES)
      ERROR_too_many_values_passed_to_test_data_stream _ ();
    if (NUM_VALUES < 1) ERROR_num_values_must_be_at_least_one _ ();
  endgenerate

  localparam integer ACTUAL_ENTRIES = NUM_VALUES;

  reg [$clog2(ACTUAL_ENTRIES)-1:0] idx;

  // Helper: extract value and reverse index so first in list = index 0
  function automatic [DATA_WIDTH-1:0] get_value(input integer i);
    // Reverse the index: last in packed vector becomes logical index 0
    get_value = VALUES >> ((ACTUAL_ENTRIES - 1 - i) * DATA_WIDTH);
  endfunction

  always @(posedge sys_clk) begin
    if (sys_reset) begin
      idx      <= 0;
      data_out <= get_value(0);  // now first value in concatenation
    end else if (next_data_req) begin
      idx      <= (idx + 1'd1) % ACTUAL_ENTRIES;
      data_out <= get_value((idx + 1'd1) % ACTUAL_ENTRIES);
    end
  end

endmodule

// Similar to test_data_stream but instead of providing the data it 
// compare it with 'check' is high to the next value in the stream.
module test_data_checker #(
    parameter integer DATA_WIDTH = 32,
    parameter integer NUM_VALUES = 32,
    parameter integer MAX_ENTRIES = 32,
    parameter [DATA_WIDTH*32-1:0] VALUES = {32{{DATA_WIDTH{1'b0}}}}
) (
    input wire sys_clk,
    input wire sys_reset,
    input wire check,  // pulse high to trigger compare + advance
    input wire [DATA_WIDTH-1:0] data_in,  // value from DUT to verify
    output reg error_flag  // Latched

);

  wire [DATA_WIDTH-1:0] expected_data;

  test_data_stream #(
      .DATA_WIDTH   (DATA_WIDTH),
      .NUM_VALUES   (NUM_VALUES),
      .MAX_ENTRIES  (MAX_ENTRIES),
      .VALUES(VALUES)
  ) reference_stream (
      .sys_clk      (sys_clk),
      .sys_reset    (sys_reset),
      .next_data_req(check),
      .data_out     (expected_data)
  );

  always @(posedge sys_clk) begin
    if (sys_reset) begin
      error_flag <= 0;
    end else if (check) begin
      if (data_in != expected_data) begin
        error_flag <= 1;
      end
    end else begin
    end
  end

endmodule

`endif

