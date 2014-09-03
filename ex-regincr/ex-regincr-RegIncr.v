//========================================================================
// Registered Incrementer
//========================================================================
// This is a simple example of a module for a registered incrementer
// which combines a positive edge triggered register with a combinational
// +2 incrementer. We use flat register-transfer-level modeling.

`ifndef EX_REGINCR_REG_INCR_V
`define EX_REGINCR_REG_INCR_V

module ex_regincr_RegIncr
(
  input  logic       clk,
  input  logic [7:0] in,
  output logic [7:0] out
);

  // Sequential logic

  logic [7:0] temp_reg;
  always @( posedge clk )
    temp_reg <= in;

  // Combinational logic

  logic [7:0] temp_wire;
  always @(*)
    temp_wire = temp_reg + 1;

  // Combinational logic

  assign out = temp_wire + 1;

endmodule

`endif /* EX_REGINCR_REG_INCR_V */

