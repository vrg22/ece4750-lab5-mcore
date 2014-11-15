//========================================================================
// ALU for 5-Stage Pipelined Processor
//========================================================================

`ifndef LAB2_PROC_ALU_V
`define LAB2_PROC_ALU_V

`include "vc-arithmetic.v"

module lab2_proc_alu
(
  input  logic [31:0] in0,
  input  logic [31:0] in1,
  input  logic [ 3:0] fn,
  output logic [31:0] out,
  output logic        ops_eq,
  output logic        op0_zero,
  output logic        op0_neg
);

  always @(*)
  begin

    case ( fn )
      4'd0  : out = in0 + in1;                     // ADD
      4'd1  : out = in0 - in1;                     // SUB
//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more functionality here for other ALU ops!

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
      4'd2  : out = in1 << in0[4:0];               // SLL
      4'd3  : out = in0 | in1;                     // OR
      4'd4  : out = ($signed(in0) < $signed(in1)); // SLT
      4'd5  : out = (in0 < in1);                   // SLTU
      4'd6  : out = in0 & in1;                     // AND
      4'd7  : out = in0 ^ in1;                     // XOR
      4'd8  : out = ~(in0 | in1);                  // NOR
      4'd9  : out = in1 >> in0[4:0];               // SRL
      4'd10 : out = $signed(in1) >>> in0[4:0];     // SRA
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
      4'd11 : out = in0;                           // CP OP0
      4'd12 : out = in1;                           // CP OP1
      default : out = 32'b0;
    endcase

  end

  // Calculate equality, zero, negative flags

  vc_EqComparator #(32) cond_eq_comp
  (
    .in0  (in0),
    .in1  (in1),
    .out  (ops_eq)
  );

  vc_ZeroComparator #(32) cond_zero_comp
  (
    .in   (in0),
    .out  (op0_zero)
  );

  vc_EqComparator #(1) cond_neg_comp
  (
    .in0  (in0[31]),
    .in1  (1'b1),
    .out  (op0_neg)
  );

endmodule

`endif
