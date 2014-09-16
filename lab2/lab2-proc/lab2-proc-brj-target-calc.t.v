//========================================================================
// Unit Tests for Branch/Jump Target Calc Components
//========================================================================

`include "lab2-proc-brj-target-calc.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab2-proc-brj-target-calc" )

  //----------------------------------------------------------------------
  // Test lab2_proc_BrTarget
  //----------------------------------------------------------------------

  logic [31:0] t1_pc_plus4;
  logic [31:0] t1_imm_sext;
  logic [31:0] t1_br_target;

  lab2_proc_BrTarget t1_br_targ
  (
    .pc_plus4   (t1_pc_plus4),
    .imm_sext   (t1_imm_sext),
    .br_target  (t1_br_target)
  );

  task t1
  (
    input logic [31:0] pc_plus4,
    input logic [31:0] imm_sext,
    input logic [31:0] br_target
  );
  begin
    t1_pc_plus4 = pc_plus4;
    t1_imm_sext = imm_sext;
    #1;
    `VC_TEST_NOTE_INPUTS_2( pc_plus4, imm_sext );
    `VC_TEST_NET( t1_br_target, br_target );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "lab2_proc_BrTarget" )
  begin
    //  pc_plus4      imm_sext      br_target
    t1( 32'h00000000, 32'h00000000, 32'h00000000 );
    t1( 32'hfee00dd0, 32'h00000000, 32'hfee00dd0 );
    t1( 32'h042309ec, 32'h00000d25, 32'h04233e80 );
    t1( 32'h00399e00, 32'hffffffa3, 32'h00399c8c );
    t1( 32'h00000000, 32'h00201ee2, 32'h00807b88 );
    t1( 32'hffffffff, 32'hffffffff, 32'hfffffffb );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test lab2_proc_JTarget
  //----------------------------------------------------------------------

  logic [31:0] t2_pc_plus4;
  logic [25:0] t2_imm_target;
  logic [31:0] t2_j_target;

  lab2_proc_JTarget t2_j_targ
  (
    .pc_plus4   (t2_pc_plus4),
    .imm_target (t2_imm_target),
    .j_target   (t2_j_target)
  );

  task t2
  (
    input logic [31:0] pc_plus4,
    input logic [25:0] imm_target,
    input logic [31:0] j_target
  );
  begin
    t2_pc_plus4 = pc_plus4;
    t2_imm_target = imm_target;
    #1;
    `VC_TEST_NOTE_INPUTS_2( pc_plus4, imm_target );
    `VC_TEST_NET( t2_j_target, j_target );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "lab2_proc_JTarget" )
  begin
    //  pc_plus4      imm_target   j_target
    t2( 32'h00000000, 26'h0000000, 32'h00000000 );
    t2( 32'hfee00dd0, 26'h0000000, 32'hfc000000 );
    t2( 32'h042309ec, 26'h0000d25, 32'h04003494 );
    t2( 32'h00399e00, 26'h3ffffa3, 32'h03fffe8c );
    t2( 32'h00000000, 26'h0201ee2, 32'h00807b88 );
    t2( 32'hffffffff, 26'h3ffffff, 32'hfffffffc );
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

