//========================================================================
// Router Adaptive Input Terminal Ctrl Unit Tests
//========================================================================

`include "lab4-net-RouterAdaptiveInputTerminalCtrl.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab4-net-RouterAdaptiveInputTerminalCtrl" )

  //----------------------------------------------------------------------
  // Test input control with adaptive routing
  //----------------------------------------------------------------------

  logic [2:0]   t1_dest;
  logic         t1_in_val;
  logic         t1_in_rdy;
  logic [2:0]   t1_num_free_west;
  logic [2:0]   t1_num_free_east;
  logic [1:0]   t1_forw_free_one;
  logic [1:0]   t1_forw_free_two;
  logic [1:0]   t1_backw_free_one;
  logic [1:0]   t1_backw_free_two;
  logic [2:0]   t1_reqs;
  logic [2:0]   t1_grants;

  lab4_net_RouterAdaptiveInputTerminalCtrl
  #(
    .p_router_id      (2),                // Default 2. Change to 7 for Basic Test 5. Other tests should fail
    .p_num_routers    (8),
    .p_num_free_nbits (3),
    .f                (2)
  )
  t1_adaptive_input_term_ctrl
  (
    .dest           (t1_dest  ),
    .in_val         (t1_in_val),
    .in_rdy         (t1_in_rdy),
    .num_free_west  (t1_num_free_west),
    .num_free_east  (t1_num_free_east),
    .forw_free_one  (t1_forw_free_one),
    .forw_free_two  (t1_forw_free_two),
    .backw_free_one (t1_backw_free_one),
    .backw_free_two (t1_backw_free_two),
    .reqs           (t1_reqs  ),
    .grants         (t1_grants)
  );

  // Helper task

  task t1
  (
    input logic [2:0]  dest,
    input logic        in_val,
    input logic        in_rdy,
    input logic [1:0]  num_free_west,
    input logic [1:0]  num_free_east,
    input logic [1:0]  forw_free_one,
    input logic [1:0]  forw_free_two,
    input logic [1:0]  backw_free_one,
    input logic [1:0]  backw_free_two,
    input logic [2:0]  reqs,
    input logic [2:0]  grants
  );
  begin
    t1_dest           = dest;
    t1_in_val         = in_val;
    t1_num_free_west  = num_free_west;
    t1_num_free_east  = num_free_east;
    t1_forw_free_one  = forw_free_one;
    t1_forw_free_two  = forw_free_two;
    t1_backw_free_one = backw_free_one;
    t1_backw_free_two = backw_free_two;
    t1_grants         = grants;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in_val, dest, grants );
    `VC_TEST_NOTE_INPUTS_2( num_free_west, num_free_east );
    `VC_TEST_NOTE_INPUTS_2( forw_free_one, forw_free_two );
    `VC_TEST_NOTE_INPUTS_2( backw_free_one, backw_free_two );
    `VC_TEST_NET( t1_in_rdy,  in_rdy );
    `VC_TEST_NET( t1_reqs, reqs );

  end
  endtask

  // Test case

  //----------------------------------------------------------------------
  // basic test 1: sending a message to self
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test 1: sending a message to self" )
  begin

    // Testing sending a message to self

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h2, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b11, 2'b11, 3'b010, 3'bx1x );

  end
  `VC_TEST_CASE_END

  // add more test cases

  //----------------------------------------------------------------------
  // basic test 2: dest greater than source, route east
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test 2: dest greater than source, route east" )
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h4, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b11, 2'b11, 3'b100, 3'b1xx );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test 3: dest greater than source, route west
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test 3: dest greater than source, route west" )
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h7, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b11, 2'b11, 3'b001, 3'bxx1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test 4: dest smaller than source, route west
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "basic test 4: dest smaller than source, route west" )
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h0, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b11, 2'b11, 3'b001, 3'bxx1 );

  end
  `VC_TEST_CASE_END  

  /* //----------------------------------------------------------------------              // CHANGE ROUTER ID TO 7 FOR BASIC TEST 5
  // basic test 5: dest smaller than source, route east                                    
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "basic test 5: dest smaller than source, route east" )          // tests equidistance routing
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h0, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b11, 2'b11, 3'b100, 3'b1xx );

  end
  `VC_TEST_CASE_END  */

  //----------------------------------------------------------------------
  // basic test 6: heavy congestion on west, route east
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "basic test 6: heavy congestion on west, route east" )
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h6, 1'b1, 1'b1, 2'h2, 2'h2, 2'b11, 2'b11, 2'b00, 2'b00, 3'b100, 3'b1xx );

  end
  `VC_TEST_CASE_END  

  //----------------------------------------------------------------------
  // basic test 7: heavy congestion on east, route west
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "basic test 6: heavy congestion on east, route west" )
  begin

    //  dest  val   rdy   fr_w  fr_e  ff1    ff2    bf1    bf2    reqs    grants
    t1( 3'h6, 1'b1, 1'b1, 2'h2, 2'h2, 2'b00, 2'b00, 2'b11, 2'b11, 3'b001, 3'bxx1 );

  end
  `VC_TEST_CASE_END  


  `VC_TEST_SUITE_END
endmodule


