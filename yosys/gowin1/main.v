// Testing writing at full speed to an FTDI sync fifo.

module main #(
    // parameter integer DEPTH = 512,  // Fifo depth 
    parameter integer DEPTH = 256,  // Fifo depth 
    parameter integer WIDTH = 8  // Fifo width
) (
    input ext_clk,
    output [7:0] test
);

  wire sys_clk;
  wire pll_locked;

  // Slow the 27mhz to about 4Mhz to easy logic analyzer logging.
  pll pll (
      .clock_in(ext_clk),
      . clock_out(sys_clk),
      .   locked(pll_locked)
  );

  // Generates sys_reset high for the first 10 clocks.
  reg sys_reset;
  reg [3:0] sys_reset_counter = 0;
  always @(posedge sys_clk) begin
    if (!pll_locked) begin
      sys_reset <= 1;
      sys_reset_counter <= 0;
    end else if (sys_reset_counter < 10) begin
      sys_reset <= 1;
      sys_reset_counter <= sys_reset_counter + 1;
    end else begin
      sys_reset <= 0;
    end
  end

  // Generate a signal that simulates alternating blocking
  // and enabling of read bytes consumption.
  // read data transmission.
  reg [9:0] rd_txe_counter = 0;
  reg rd_txe;
  always @(posedge sys_clk) begin
    if (sys_reset) begin
      rd_txe_counter <= 0;
      rd_txe <= 0;
    end
    if (rd_txe_counter >= 10) begin
      rd_txe_counter <= 0;
      rd_txe <= !rd_txe;
    end else begin
      rd_txe_counter <= rd_txe_counter + 1;
    end
  end

  // Fifo write signals.
  wire full;
  reg [WIDTH-1:0] din;

  // Fifo read signals.
  wire empty;
  wire [WIDTH-1:0] dout;

  // Indicates if an additional byte is available for reading.
  wire rd_avail = !empty;



  // Indicates if the byte in din will be written 
  // to the fifo on next clock.
  wire wr_en = !full;

  // Indicates if the next byte from the fifo will be read into
  // the dout reg on the next clock.
  wire rd_en = rd_avail && rd_txe;



  wire [2:0] probe;

  // Async fifo from 
  // https://github.com/HarshitP2006/Dual-Clock-Asynchronous-FIFO-Verilog
  async_fifo #(
      .DATA_WIDTH(WIDTH),
      .DEPTH(DEPTH)
  ) async_fifo (
      .wr_clk(sys_clk),
      .wr_rst(sys_reset),
      .wr_en(wr_en),
      .din(din),
      .full(full),
      .almost_full(),

      .rd_clk(sys_clk),
      .rd_rst(sys_reset),
      .rd_en(rd_en),
      .dout(dout),
      .empty(empty),
      .almost_empty(),

      .probe(probe)
  );

  // Increment din on each write to the fifo to
  // generate a consecutive byte pattern.
  always @(posedge sys_clk) begin
    if (sys_reset) begin
      din <= 0;
    end else if (wr_en && ~full) begin
      // Here we had an active write.
      din <= din + 1;
    end
  end

  // Test outputs.
  assign test[7] = sys_clk;
  assign test[6] = rd_txe;
  assign test[5] = rd_en;
  assign test[4] = dout[0];

  assign test[3] = probe[0];
  assign test[2] = probe[1];
  assign test[1] = probe[2];
  assign test[0] = 1'b0;
endmodule
