//========================================================================
// Router Output Ctrl Unit Tests
//========================================================================

`include "lab4-net-RouterOutputCtrl.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab4-net-RouterOutputCtrl" )

  //----------------------------------------------------------------------
  // Test output control with round robin arbitration
  //----------------------------------------------------------------------

  logic        t1_reset;
  logic [2:0]  t1_reqs;
  logic [2:0]  t1_grants;

  logic        t1_out_val;
  logic        t1_out_rdy;
  logic [1:0]  t1_xbar_sel;

  lab4_net_RouterOutputCtrl t1_output_ctrl
  (
    .clk       (clk        ),
    .reset     (t1_reset   ),

    .reqs      (t1_reqs    ),
    .grants    (t1_grants  ),

    .out_val   (t1_out_val ),
    .out_rdy   (t1_out_rdy ),
    .xbar_sel  (t1_xbar_sel)
  );

  // Helper task

  task t1
  (
    input logic [2:0]  reqs,
    input logic [2:0]  grants,

    input logic        out_val,
    input logic        out_rdy,
    input logic [1:0]  xbar_sel
  );
  begin
    t1_reqs    = reqs;
    t1_out_rdy = out_rdy;
    #1;
    `VC_TEST_NOTE_INPUTS_2( reqs, out_rdy );
    `VC_TEST_NET( t1_grants,   grants );
    `VC_TEST_NET( t1_out_val,  out_val );
    `VC_TEST_NET( t1_xbar_sel, xbar_sel );
    #9;
  end
  endtask

  //----------------------------------------------------------------------
  // basic test
  //----------------------------------------------------------------------

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++
  `VC_TEST_CASE_BEGIN( 1, "basic test" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  reqs    grants  val   rdy   sel
    t1( 3'b000, 3'b000, 1'b0, 1'b0, 2'h? );
    t1( 3'b100, 3'b000, 1'b?, 1'b0, 2'h? );
    t1( 3'b100, 3'b100, 1'b1, 1'b1, 2'h2 );
    t1( 3'b010, 3'b010, 1'b1, 1'b1, 2'h1 );
    t1( 3'b001, 3'b001, 1'b1, 1'b1, 2'h0 );
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 2'b0?);
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 2'b0?);
    t1( 3'b111, 3'b???, 1'b1, 1'b1, 2'h? );
    t1( 3'b101, 3'b000, 1'b?, 1'b0, 2'h? );
    t1( 3'b000, 3'b000, 1'b0, 1'b1, 2'h? );

  end
  `VC_TEST_CASE_END
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++
//   `VC_TEST_CASE_BEGIN( 1, "basic test" )
//   begin
// 
//     #1;  t1_reset = 1'b1;
//     #20; t1_reset = 1'b0;
// 
//     // Testing a single ready request
// 
//     //  reqs    grants  val   rdy   sel
//     t1( 3'b100, 3'b100, 1'b1, 1'b1, 2'h2 );
// 
//   end
//   `VC_TEST_CASE_END
// 
// 
//   // add more test cases
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++

  `VC_TEST_SUITE_END
endmodule


