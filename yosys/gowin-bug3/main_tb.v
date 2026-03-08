`timescale 1ns / 1ps

module main_tb;

  // Board clock.
  reg     sys_clk = 0;
  integer clk_num = 0;

  // Sys clock.
  always begin
    #10 sys_clk = ~sys_clk;
    if (sys_clk) clk_num = clk_num + 1;
  end


  wire probe_clk;
  wire probe_rd_en;
  wire probe_mem_out;
  wire probe_reg_out;

  // DUT instantiation
  main #(
      .ADDR_WIDTH(8)
  ) main (
      .sys_clk(sys_clk),

      // External test probes
      .probe_clk(probe_clk),
      .probe_rd_en(probe_rd_en),
      .probe_mem_out(probe_mem_out),
      .probe_reg_out(probe_reg_out)
  );

  // Test main
  initial begin
    $dumpvars(0, main_tb);

    repeat (500) @(posedge sys_clk);

    // End of test
    $display("End of simulation");
    $finish;
  end


endmodule
