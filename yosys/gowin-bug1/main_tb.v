`timescale 1ns / 1ps

module main_tb;

  // Board clock.
  reg           ext_clk = 0;
  integer       clk_num = 0;

  // Sys clock.
  always begin
    #10 ext_clk = ~ext_clk;
    if (ext_clk) clk_num = clk_num + 1;
  end

  // DUT instantiation
  main #(
      .DEPTH(256),
      .DATA_WIDTH(8)
  ) main (
      .ext_clk(ext_clk),
      .test()
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
