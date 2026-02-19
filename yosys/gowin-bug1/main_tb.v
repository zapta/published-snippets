`timescale 1ns / 1ps

module main_tb;

  // Board clock.
  reg     ext_clk = 0;
  integer clk_num = 0;

  // Sys clock.
  always begin
    #10 ext_clk = ~ext_clk;
    if (ext_clk) clk_num = clk_num + 1;
  end


  wire probe_sync;
  wire probe_clk;
  wire prob_data_en;
  wire probe_data_out;

  // DUT instantiation
  main #(
      .DEPTH(256),
      .DATA_WIDTH(8)
  ) main (
      .ext_clk(ext_clk),

      // External test probes
      .probe_sync(probe_sync),
      .probe_clk(probe_clk),
      .prob_data_en(prob_data_en),
      .probe_data_out(probe_data_out)
  );

  // Test main
  initial begin
    $dumpvars(0, main_tb);

    repeat (500) @(posedge ext_clk);

    // End of test
    $display("End of simulation");
    $finish;
  end


endmodule
