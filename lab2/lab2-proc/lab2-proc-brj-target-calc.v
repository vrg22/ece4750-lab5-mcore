//========================================================================
// Branch/Jump Target Calc Components for 5-Stage Pipelined Processor
//========================================================================

`ifndef LAB2_PROC_BRJ_TARGET_CALC_V
`define LAB2_PROC_BRJ_TARGET_CALC_V

//------------------------------------------------------------------------
// Branch Target calculation module
//------------------------------------------------------------------------

module lab2_proc_BrTarget
(
  input  logic [31:0] pc_plus4,
  input  logic [31:0] imm_sext,
  output logic [31:0] br_target
);

  assign br_target = pc_plus4 + ( imm_sext << 2 );

endmodule

//------------------------------------------------------------------------
// Jump Target calculation module
//------------------------------------------------------------------------

module lab2_proc_JTarget
(
  input  logic [31:0] pc_plus4,
  input  logic [25:0] imm_target,
  output logic [31:0] j_target
);

  assign j_target = { pc_plus4[31:26], ( imm_target << 2 ) };

endmodule

`endif
