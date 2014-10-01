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
  
  logic [31:0] sll_out;
  logic        lt_out;
  logic [31:0] srl_out;
  logic [31:0] sra_out;
  logic        lt_signed_out;

  always @(*)
  begin

    case ( fn )
      4'd0  : out = in0 + in1;                       // ADD
      4'd1  : out = in0 - in1;                       // SUB
      4'd2  : out = sll_out;                         // SLL
      4'd3  : out = in0 | in1;                       // OR
      4'd4  : out = { 31'd0, lt_out  };              // LT Unsigned
      4'd5  : out = in0 & in1;                       // AND
      4'd6  : out = in0 ^ in1;                       // XOR
      4'd7  : out = in0 ~| in1;                      // NOR
      4'd8  : out = in0 ^~ in1;                      // XNOR
      4'd9  : out = srl_out;                         // SRL
      4'd10 : out = $signed(in1) >>> in0[4:0];       // SRA
      4'd11 : out = in0;                             // CP OP0
      4'd12 : out = in1;                             // CP OP1
      4'd13 : out = { 31'd0, lt_signed_out };        // LT Signed
      4'd14 : out = { in1[15:0] , 16'd0 };           // LUI
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

  vc_LeftLogicalShifter #(32,5) left_log_shifter
  (
    .in     (in1),
    .shamt  (in0[4:0]),
    .out    (sll_out)
  );

  vc_LtComparator #(32) lt_comp
  (
    .in0    (in0),
    .in1    (in1),
    .out    (lt_out)
  );

  vc_LtComparator #(32) lt_signed_comp
  (
    .in0    ($signed(in0)),
    .in1    ($signed(in1)),
    .out    (lt_signed_out)
  );

  vc_RightLogicalShifter #(32,5) right_log_shifter
  (
    .in     (in1),
    .shamt  (in0[4:0]),
    .out    (srl_out)
  );

endmodule

`endif  /*LAB2_PROC_ALU_V */
