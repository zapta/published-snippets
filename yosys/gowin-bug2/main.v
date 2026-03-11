// Testing writing at full speed to an FTDI sync fifo.

module main #(
    parameter integer DEPTH = 256,     // Fifo depth
    parameter integer DATA_WIDTH = 8   // Fifo width
) (
    input ext_clk,

    // Probes for testing.
    output probe_sync,      // Sync oscilloscope of negative edge
    output probe_clk,       // D-reg clock (rising edge)
    output prob_data_en,    // D-reg enable
    output probe_data_out,  // D-reg output
    output probe_aux_0,     // Auxiliary probe.
    output probe_aux_1,     // Auxiliary probe.
    output probe_aux_2,     // Auxiliary probe.
    output probe_aux_3      // Auxiliary probe.
);

  wire sys_clk;
  wire pll_locked;

  // Slow the 27mhz to about 4Mhz to easy logic analyzer logging.
  pll pll (
      .clock_in(ext_clk),
      .clock_out(sys_clk),
      .locked(pll_locked)
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
  reg [DATA_WIDTH-1:0] din;

  // Fifo read signals.
  wire empty;
  wire [DATA_WIDTH-1:0] dout;

  // Indicates if an additional byte is available for reading.
  wire rd_avail = !empty;

  // Indicates if the byte in din will be written 
  // to the fifo on next clock.
  wire wr_en = !full;

  // Indicates if the next byte from the fifo will be read into
  // the dout reg on the next clock.
  wire rd_en = rd_avail && rd_txe;

  // Async fifo from 
  // https://github.com/HarshitP2006/Dual-Clock-Asynchronous-FIFO-Verilog
  async_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
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

      // Probes for testing
      .probe_clk(probe_clk),
      .probe_data_en(prob_data_en),
      .probe_data_out(probe_data_out),
      .probe_aux_0(probe_aux_0),
      .probe_aux_1(probe_aux_1),
      .probe_aux_2(probe_aux_2),
      .probe_aux_3(probe_aux_3)
  );




  assign probe_sync = rd_txe;


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

endmodule
