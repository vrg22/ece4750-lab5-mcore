//=========================================================================
// IntMul Unit Test Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define LAB1_IMUL_IMPL lab1_imul_Impl
//
//  `include "lab1-imul-Impl.v"
//  `include "lab1-imul-test-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"

`include "vc-preprocessor.v"
`include "vc-test.v"
`include "vc-trace.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  logic [63:0] src_msg;
  logic        src_val;
  logic        src_rdy;
  logic        src_done;

  logic [31:0] sink_msg;
  logic        sink_val;
  logic        sink_rdy;
  logic        sink_done;

  vc_TestRandDelaySource#(64) src
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (src_max_delay),

    .val        (src_val),
    .rdy        (src_rdy),
    .msg        (src_msg),

    .done       (src_done)
  );

  `LAB1_IMUL_IMPL imul
  (
    .clk        (clk),
    .reset      (reset),

    .req_msg    (src_msg),
    .req_val    (src_val),
    .req_rdy    (src_rdy),

    .resp_msg   (sink_msg),
    .resp_val   (sink_val),
    .resp_rdy   (sink_rdy)
  );

  vc_TestRandDelaySink#(32) sink
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (sink_max_delay),

    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),

    .done       (sink_done)
  );

  assign done = src_done && sink_done;

  `VC_TRACE_BEGIN
  begin
    src.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    imul.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    sink.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `VC_PREPROCESSOR_TOSTR(`LAB1_IMUL_IMPL) )

  // Not really used, but the python-generated verilog will set this

  integer num_inputs;

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  reg         th_reset = 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  // Helper task to initialize sorce sink

  task init
  (
    input [ 9:0] i,
    input [31:0] a,
    input [31:0] b,
    input [31:0] result
  );
  begin
    th.src.src.m[i]   = { a, b };
    th.sink.sink.m[i] = result;
  end
  endtask

  // Helper task to initialize source/sink

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.vc_trace.cycles < 5000) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // Test Case: small positive * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "small positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, 32'd03, 32'd6   );
    init( 1, 32'd04, 32'd05, 32'd20  );
    init( 2, 32'd03, 32'd04, 32'd12  );
    init( 3, 32'd10, 32'd13, 32'd130 );
    init( 4, 32'd08, 32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  // Add more directed tests here as separate test cases, do not just
  // make the above test case larger. Once you have finished adding
  // directed tests, move on to adding random tests.


//----------------------------------------------------------------------
  // Test Case: products of zero, one, and negative one
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "products of zero, one, and negative one" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd00, 32'd01, 32'd00  );
    init( 1, 32'd01, 32'd00, 32'd00  );
    init( 2, 32'd00, -32'd01, 32'd00 );
    init( 3, -32'd01, 32'd00, 32'd00 );
    init( 4, 32'd01, -32'd01, -32'd01);
    init( 5, -32'd01, 32'd01, -32'd01);
    run_test;
  end
  `VC_TEST_CASE_END


//----------------------------------------------------------------------
  // Test Case: small positive * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "small positive * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, -32'd03, -32'd06  );
    init( 1, 32'd06, -32'd012, -32'd72 );
    init( 2, 32'd08, -32'd04, -32'd32  );
    init( 3, 32'd15, -32'd15, -32'd225 );
    init( 4, 32'd01, -32'd02, -32'd02  );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: small negative * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "small negative * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'd02, 32'd03, -32'd06  );
    init( 1, -32'd06, 32'd012, -32'd72 );
    init( 2, -32'd08, 32'd04, -32'd32  );
    init( 3, -32'd15, 32'd15, -32'd225 );
    init( 4, -32'd01, 32'd01, -32'd01  );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: large positive * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "large positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'hab, 32'hbc, 32'h7d94         );
    init( 1, 32'h2c, 32'h88, 32'h1760         );
    init( 2, 32'hfff, 32'hfff, 32'hffe001     );
    init( 3, 32'ha882, 32'he21, 32'h94cd4c2   );
    init( 4, 32'he8cd, 32'hd190, 32'hbe925050 );
    init( 5, 32'h5fc2, 32'h9c3b, 32'h3a7049b6 );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: large positive * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "large positive * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'hab, -32'hbc, -32'h7d94         );
    init( 1, 32'h2c, -32'h88, -32'h1760         );
    init( 2, 32'hfff, -32'hfff, -32'hffe001     );
    init( 3, 32'ha882, -32'he21, -32'h94cd4c2   );
    init( 4, 32'he8cd, -32'hd190, -32'hbe925050 );
    init( 5, 32'h5fc2, -32'h9c3b, -32'h3a7049b6 );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: large negative * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "large negative * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'hab, 32'hbc, -32'h7d94         );
    init( 1, -32'h2c, 32'h88, -32'h1760         );
    init( 2, -32'hfff, 32'hfff, -32'hffe001     );
    init( 3, -32'ha882, 32'he21, -32'h94cd4c2   );
    init( 4, -32'he8cd, 32'hd190, -32'hbe925050 );
    init( 5, -32'h5fc2, 32'h9c3b, -32'h3a7049b6 );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: large negative * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "large negative * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'hab, -32'hbc, 32'h7d94         );
    init( 1, -32'h2c, -32'h88, 32'h1760         );
    init( 2, -32'hfff, -32'hfff, 32'hffe001     );
    init( 3, -32'ha882, -32'he21, 32'h94cd4c2   );
    init( 4, -32'he8cd, -32'hd190, 32'hbe925050 );
    init( 5, -32'h5fc2, -32'h9c3b, 32'h3a7049b6 );
    run_test;
  end
  `VC_TEST_CASE_END

/*
  //----------------------------------------------------------------------
  // Test Case: products with low order bits masked off
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "products with low order bits masked off" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'hax, 32'hbx, 32'h7d94           );
    init( 1, 32'hax, 32'hbx, 32'h7d94           );
    init( 3, -32'ha88x, -32'he2x, 32'h94cd4c2   );
    init( 2, -32'hffx, 32'hffx, 32'hffe001      );
    init( 4, 32'he8cx, 32'hd19x, 32'hbe925050   );
    init( 5, 32'h5fcx, -32'h9c3x, 32'h3a7049b6  );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: products with middle bits masked off
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "products with middle bits masked off" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'hxa, 32'hbx, 32'h7d94          );
    init( 1, -32'h2x, 32'h8x, 32'h1760         );
    init( 2, -32'hffx, -32'hffx, 32'hffe001    );
    init( 3, 32'ha88x, 32'he2x, 32'h94cd4c2    );
    init( 4, 32'he8cx, -32'hd19x, 32'hbe925050 );
    run_test;
  end
  `VC_TEST_CASE_END */


  //----------------------------------------------------------------------
  // Test Case: sparse number * sparse number
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "sparse number * sparse number" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'h82, 32'h01, 32'h82             );
    init( 1, -32'h20, 32'd08, -32'h100          );
    init( 2, -32'h808, -32'h4201, 32'h2121808   );
    init( 3, 32'h1001, 32'h0101, 32'h101101     );
    init( 4, 32'h4020, -32'h0110, -32'h442200    );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: dense number * dense number
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "dense number * dense number" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'hf7, 32'hbf, 32'hb849           );
    init( 1, -32'hcc, -32'h7d, 32'h639c         );
    init( 2, 32'hfff, -32'hfff, -32'hffe001     );
    init( 3, -32'hb7de, 32'heddb, -32'haad5d0ea );
    init( 4, -32'hcdfe, -32'hfeed, 32'hcd20b826 );
    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // Test Case: random small
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "random small" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random small w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 12, "random small w/ random delays" )
  begin
    init_rand_delays( 3, 14 );
    `include "lab1-imul-gen-input_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 13, "random large" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 14, "random large w/ random delays" )
  begin
    init_rand_delays( 20, 5 );
    `include "lab1-imul-gen-input_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END



  `VC_TEST_SUITE_END

endmodule

