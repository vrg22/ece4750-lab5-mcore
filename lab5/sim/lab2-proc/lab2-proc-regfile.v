//========================================================================
// Register File for 5-Stage Pipelined Processor
//========================================================================

`ifndef LAB2_PROC_REGFILE_V
`define LAB2_PROC_REGFILE_V

`include "vc-regfiles.v"

//------------------------------------------------------------------------
// Register file specialized for r0 == 0
//------------------------------------------------------------------------

module lab2_proc_Regfile
(
  input  logic        clk,
  input  logic        reset,

  input  logic  [4:0] read_addr0,
  output logic [31:0] read_data0,

  input  logic  [4:0] read_addr1,
  output logic [31:0] read_data1,

  input  logic        write_en,
  input  logic  [4:0] write_addr,
  input  logic [31:0] write_data
);

  // these wires are to be hooked up to the actual register file read
  // ports

  logic [31:0] rf_read_data0;
  logic [31:0] rf_read_data1;

  vc_Regfile_2r1w
  #(
    .p_data_nbits  (32),
    .p_num_entries (32)
  )
  rfile
  (
    .clk         (clk),
    .reset       (reset),
    .read_addr0  (read_addr0),
    .read_data0  (rf_read_data0),
    .read_addr1  (read_addr1),
    .read_data1  (rf_read_data1),
    .write_en    (write_en),
    .write_addr  (write_addr),
    .write_data  (write_data)
  );

  // we pick 0 value when either read address is 0
  assign read_data0 = ( read_addr0 == 5'd0 ) ? 32'd0 : rf_read_data0;
  assign read_data1 = ( read_addr1 == 5'd0 ) ? 32'd0 : rf_read_data1;

endmodule

`endif
