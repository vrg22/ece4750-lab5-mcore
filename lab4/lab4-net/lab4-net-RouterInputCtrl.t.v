//========================================================================
// Router Input Ctrl Unit Tests
//========================================================================

`include "lab4-net-RouterInputCtrl.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab4-net-RouterInputCtrl" )

  //----------------------------------------------------------------------
  // Test input control with pass through routing
  //----------------------------------------------------------------------

  logic [2:0]  t1_dest;
  logic        t1_in_val;
  logic        t1_in_rdy;
  logic [2:0]  t1_reqs;
  logic [2:0]  t1_grants;

  lab4_net_RouterInputCtrl
  #(
    .p_router_id    (2),
    .p_num_routers  (8)
  )
  t1_input_ctrl
  (
    .dest   (t1_dest  ),
    .in_val (t1_in_val),
    .in_rdy (t1_in_rdy),
    .reqs   (t1_reqs  ),
    .grants (t1_grants)
  );

  // Helper task

  task t1
  (
    input logic [2:0]  dest,
    input logic        in_val,
    input logic        in_rdy,
    input logic [2:0]  reqs,
    input logic [2:0]  grants
  );
  begin
    t1_dest   = dest;
    t1_in_val = in_val;
    t1_grants = grants;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in_val, dest, grants );
    `VC_TEST_NET( t1_in_rdy,  in_rdy );
    `VC_TEST_NET( t1_reqs, reqs );

  end
  endtask

  // Test cases

  //----------------------------------------------------------------------
  // basic test 1: sending a message to self
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test 1: sending a message to self" )
  begin

    // Testing sending a message to self

    //  dest  val   rdy   reqs    grants
    t1( 3'h2, 1'b1, 1'b1, 3'b010, 3'bx1x );

  end
  `VC_TEST_CASE_END

  // add more test cases

  //----------------------------------------------------------------------
  // basic test 2: sending a message east
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test 2: sending a message east" )
  begin

    //  dest  val   rdy   reqs    grants
    t1( 3'h7, 1'b1, 1'b1, 3'b100, 3'b1xx );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test 3: sending a message west
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test 3: sending a message west" )
  begin

    //  dest  val   rdy   reqs    grants
    t1( 3'h0, 1'b1, 1'b1, 3'b001, 3'bxx1 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule


