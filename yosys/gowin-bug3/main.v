// Testing writing at full speed to an FTDI sync fifo.

module main #(
    parameter integer ADDR_WIDTH = 8,  // Fifo address width
    parameter integer DATA_WIDTH = 8   // Fifo width
) (
    input sys_clk,

    // Probes for testing.
    output probe_clk,
    output probe_rd_en,
    output probe_mem_out,
    output probe_reg_out

);

  // Generates sys_reset high for the first 10 clocks.
  reg sys_reset;
  reg [3:0] sys_reset_counter = 0;
  always @(posedge sys_clk) begin
    if (sys_reset_counter < 10) begin
      sys_reset <= 1;
      sys_reset_counter <= sys_reset_counter + 1;
    end else begin
      sys_reset <= 0;
    end
  end

  reg [ADDR_WIDTH-1:0] wr_addr;
  reg [DATA_WIDTH-1:0] wr_data;

  reg [ADDR_WIDTH-1:0] rd_addr;
  reg [DATA_WIDTH-1:0] rd_data;

  reg [DATA_WIDTH-1:0] mem[00:2**ADDR_WIDTH-1];

  assign probe_clk = sys_clk;
  assign probe_rd_en = wr_data[ADDR_WIDTH-1];
  assign probe_mem_out = mem[rd_addr][0];
  // assign probe_reg_out = rd_data[0];
  assign probe_reg_out = 0;

  always @(posedge sys_clk) begin
    if (sys_reset) begin
      wr_addr <= 0;
      wr_data <= 0;
      // rd_addr <= 0;
      // rd_data <= 0;
    end else begin
      // if (probe_rd_en) begin
      //   rd_data <= mem[rd_addr];
      // end
      wr_data <= wr_data + 1;
      mem[wr_addr] <= wr_data;
    end
  end

  always @(posedge sys_clk) begin
    if (sys_reset) begin
      // wr_addr <= 0;
      // wr_data <= 0;
      rd_addr <= 1;
      rd_data <= 0;
    end else begin
      if (probe_rd_en) begin
        rd_data <= mem[rd_addr];
      end
      // wr_data <= wr_data + 1;
      // mem[wr_addr] <= wr_data;
    end
  end

endmodule
