//========================================================================
// ex-regincr-RegIncr Unit Tests
//========================================================================

`include "ex-regincr-RegIncr.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "ex-regincr-RegIncr" )

  //----------------------------------------------------------------------
  // Test ex_regincr_RegIncr
  //----------------------------------------------------------------------

  logic [7:0] t1_in;
  logic [7:0] t1_out;

  ex_regincr_RegIncr t1_reg_incr
  (
    .clk  (clk),
    .in   (t1_in),
    .out  (t1_out)
  );

  // Helper task

  task t1
  (
    input logic [7:0] in,
    input logic [7:0] out
  );
  begin
    t1_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t1_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple" )
  begin

    #1;

    t1( 8'h00, 8'h?? );
    t1( 8'h13, 8'h02 );
    t1( 8'h27, 8'h15 );
    t1( 8'hxx, 8'h29 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

