//========================================================================
// ex-sorter-MinMaxUnit Unit Tests
//========================================================================

`include "ex-sorter-MinMaxUnit.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "ex-sorter-MinMaxUnit" )

  //----------------------------------------------------------------------
  // Test ex_sorter_MinMaxUnit
  //----------------------------------------------------------------------

  logic [7:0] t1_in0;
  logic [7:0] t1_in1;
  logic [7:0] t1_out_min;
  logic [7:0] t1_out_max;

  ex_sorter_MinMaxUnit#(8) t1_min_max_unit
  (
    .in0     (t1_in0),
    .in1     (t1_in1),
    .out_min (t1_out_min),
    .out_max (t1_out_max)
  );

  // Helper task

  task t1
  (
    input logic [7:0] in0,
    input logic [7:0] in1,
    input logic [7:0] out_min,
    input logic [7:0] out_max
  );
  begin
    t1_in0 = in0;
    t1_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t1_out_min, out_min );
    `VC_TEST_NET( t1_out_max, out_max );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple" )
  begin

    #1;

    //  in0    in1    min    max

    t1( 8'h01, 8'h02, 8'h01, 8'h02 );
    t1( 8'h02, 8'h01, 8'h01, 8'h02 );
    t1( 8'h01, 8'h01, 8'h01, 8'h01 );
    t1( 8'h00, 8'h00, 8'h00, 8'h00 );

    t1( 8'hff, 8'hfe, 8'hfe, 8'hff );
    t1( 8'hfe, 8'hff, 8'hfe, 8'hff );
    t1( 8'hff, 8'h7f, 8'h7f, 8'hff );
    t1( 8'h7f, 8'hff, 8'h7f, 8'hff );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

