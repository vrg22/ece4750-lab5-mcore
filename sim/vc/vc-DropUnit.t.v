//========================================================================
// Unit Tests for Drop Unit
//========================================================================

`include "vc-DropUnit.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-DropUnit" )

  //----------------------------------------------------------------------
  // Test vc_DropUnit
  //----------------------------------------------------------------------

  logic        t1_reset;
  logic        t1_drop;

  logic [31:0] t1_in_msg;
  logic        t1_in_val;
  logic        t1_in_rdy;

  logic [31:0] t1_out_msg;
  logic        t1_out_val;
  logic        t1_out_rdy;


  vc_DropUnit #(32) drop_unit
  (
    .clk      (clk),
    .reset    (t1_reset),
    .drop     (t1_drop),

    .in_msg   (t1_in_msg),
    .in_val   (t1_in_val),
    .in_rdy   (t1_in_rdy),

    .out_msg  (t1_out_msg),
    .out_val  (t1_out_val),
    .out_rdy  (t1_out_rdy)
  );

  // Helper task

  task t1
  (
    input logic        drop,

    input logic [31:0] in_msg,
    input logic        in_val,
    input logic        in_rdy,

    input logic [31:0] out_msg,
    input logic        out_val,
    input logic        out_rdy
  );
  begin
    t1_drop = drop;

    t1_in_msg = in_msg;
    t1_in_val = in_val;

    t1_out_rdy = out_rdy;

    #1;
    `VC_TEST_NET( t1_in_rdy,  in_rdy );
    `VC_TEST_NET( t1_out_msg, out_msg );
    `VC_TEST_NET( t1_out_rdy, out_rdy );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple" )
  begin

    // reset

    #1;     t1_reset = 1'b1;
    #20;    t1_reset = 1'b0;

    //  drop   in_msg    in_val in_rdy out_msg   out_val out_rdy
    t1( 1'b0,  32'h1111, 1'b0,  1'b0,  32'h????, 1'b0,   1'b0 );
    t1( 1'b0,  32'h2222, 1'b0,  1'b1,  32'h????, 1'b0,   1'b1 );
    t1( 1'b0,  32'h3333, 1'b1,  1'b0,  32'h3333, 1'b1,   1'b0 );
    t1( 1'b0,  32'h4444, 1'b1,  1'b1,  32'h4444, 1'b1,   1'b1 );
    t1( 1'b1,  32'h5555, 1'b0,  1'b0,  32'h????, 1'b0,   1'b0 );
    t1( 1'b0,  32'h6666, 1'b1,  1'b1,  32'h????, 1'b0,   1'b1 );
    t1( 1'b1,  32'h7777, 1'b1,  1'b1,  32'h????, 1'b0,   1'b1 );
    t1( 1'b1,  32'h8888, 1'b0,  1'b1,  32'h????, 1'b0,   1'b1 );
    t1( 1'b0,  32'h9999, 1'b1,  1'b1,  32'h????, 1'b0,   1'b1 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

