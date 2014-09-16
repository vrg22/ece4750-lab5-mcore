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
// add more functionality here for other ALU ops!

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
