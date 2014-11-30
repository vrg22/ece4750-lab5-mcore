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
  // basic test 1: single ready request going west
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test 1: single ready request going west" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    // Testing a single ready request

    //  reqs    grants  val   rdy   sel
    t1( 3'b001, 3'b001, 1'b1, 1'b1, 2'h0 );

  end
  `VC_TEST_CASE_END


  // add more test cases

  //----------------------------------------------------------------------
  // basic test 2: single ready request going to self
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test 2: single ready request going to self" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  reqs    grants  val   rdy   sel
    t1( 3'b010, 3'b010, 1'b1, 1'b1, 2'h1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test 3: single ready request going east
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test 3: single ready request going east" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  reqs    grants  val   rdy   sel
    t1( 3'b100, 3'b100, 1'b1, 1'b1, 2'h2 );

  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule


