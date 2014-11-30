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

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Test Case: small negative * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "small negative * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'd02, 32'd03, -32'd6   );
    init( 1, -32'd04, 32'd05, -32'd20  );
    init( 2, -32'd03, 32'd04, -32'd12  );
    init( 3, -32'd10, 32'd13, -32'd130 );
    init( 4, -32'd08, 32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: small positive * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "small positive * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, -32'd03, -32'd6   );
    init( 1, 32'd04, -32'd05, -32'd20  );
    init( 2, 32'd03, -32'd04, -32'd12  );
    init( 3, 32'd10, -32'd13, -32'd130 );
    init( 4, 32'd08, -32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: small negative * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "small negative * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'd02, -32'd03, 32'd6   );
    init( 1, -32'd04, -32'd05, 32'd20  );
    init( 2, -32'd03, -32'd04, 32'd12  );
    init( 3, -32'd10, -32'd13, 32'd130 );
    init( 4, -32'd08, -32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: large positive * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "large positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'h0bcd0000, 32'h0000abcd, 32'h62290000 );
    init( 1, 32'h0fff0000, 32'h0000ffff, 32'hf0010000 );
    init( 2, 32'h0fff0000, 32'h0fff0000, 32'h00000000 );
    init( 3, 32'h04e5f14d, 32'h7839d4fc, 32'h10524bcc );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: large negative * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "large negative * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'h80000001, 32'h80000001, 32'h00000001);
    init( 1, 32'h8000abcd, 32'h8000ef00, 32'h20646300);
    init( 2, 32'h80340580, 32'h8aadefc0, 32'h6fa6a000);
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random small
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "random small" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "random large" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random lomask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "random lomask" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_lomask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random himask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "random himask" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_himask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random lohimask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "random lohimask" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_lohimask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random himask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 12, "random sparse" )
  begin
    init_rand_delays( 0, 0 );
    `include "lab1-imul-gen-input_sparse.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random small w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 13, "random small w/ random delays" )
  begin
    init_rand_delays( 3, 14 );
    `include "lab1-imul-gen-input_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 14, "random large w/ random delays" )
  begin
    init_rand_delays( 3, 14 );
    `include "lab1-imul-gen-input_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  `VC_TEST_SUITE_END
endmodule

