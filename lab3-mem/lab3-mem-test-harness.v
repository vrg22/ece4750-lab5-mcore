//========================================================================
// Cache Test Harness
//========================================================================
// This harness is meant to be instatiated for a specific implementation
// of a memory system module and optionally a cache implementation using
// the special IMPL defines like this:
//
// `define LAB3_CACHE_IMPL     lab3_mem_BlockingCacheBase
// `define LAB3_MEM_IMPL_STR  "lab3-mem-BlockingCacheBase"
//
// `include "lab3-mem-BlockingCacheBase.v"
// `include "lab3-mem-test-harness.v"

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"
`include "vc-trace.v"

`include "vc-TestRandDelayMem_1port.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
(
  input  logic        clk,
  input  logic        reset,
  input  logic        mem_clear,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] mem_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  // Local parameters

  localparam c_cache_nbytes       = 256;
  localparam c_cache_opaque_nbits = 8;
  localparam c_cache_addr_nbits   = 32;
  localparam c_cache_data_nbits   = 32;

  localparam c_mem_nbytes       = 1<<16;
  localparam c_mem_opaque_nbits = 8;
  localparam c_mem_addr_nbits   = 32;
  localparam c_mem_data_nbits   = 128;

  localparam c_cache_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_cache_opaque_nbits,c_cache_addr_nbits,c_cache_data_nbits);
  localparam c_cache_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_cache_opaque_nbits,c_cache_data_nbits);

  localparam c_mem_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits);
  localparam c_mem_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_mem_opaque_nbits,c_mem_data_nbits);

  // Test source
  logic                         src_val;
  logic                         src_rdy;
  logic [c_cache_req_nbits-1:0] src_msg;
  logic                         src_done;

  vc_TestRandDelaySource#(c_cache_req_nbits) src
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),
    .done      (src_done)
  );

  // Cache under test

  logic                          sink_val;
  logic                          sink_rdy;
  logic [c_cache_resp_nbits-1:0] sink_msg;

  logic                          memreq_val;
  logic                          memreq_rdy;
  logic [c_mem_req_nbits-1:0]    memreq_msg;
  logic                          memresp_val;
  logic                          memresp_rdy;
  logic [c_mem_resp_nbits-1:0]   memresp_msg;

  `LAB3_CACHE_IMPL
  #(
    .p_mem_nbytes   (c_cache_nbytes)
  )
  cache
  (
    .clk           (clk),
    .reset         (reset),

    .cachereq_val  (src_val),
    .cachereq_rdy  (src_rdy),
    .cachereq_msg  (src_msg),

    .cacheresp_val (sink_val),
    .cacheresp_rdy (sink_rdy),
    .cacheresp_msg (sink_msg),

    .memreq_val  (memreq_val),
    .memreq_rdy  (memreq_rdy),
    .memreq_msg  (memreq_msg),

    .memresp_val (memresp_val),
    .memresp_rdy (memresp_rdy),
    .memresp_msg (memresp_msg)
  );

  //----------------------------------------------------------------------
  // Initialize the test memory
  //----------------------------------------------------------------------

  vc_TestRandDelayMem_1port
  #(
    .p_mem_nbytes   (c_mem_nbytes),
    .p_opaque_nbits (c_mem_opaque_nbits),
    .p_addr_nbits   (c_mem_addr_nbits),
    .p_data_nbits   (c_mem_data_nbits)
  )
  test_mem
  (
    .clk          (clk),
    .reset        (reset),
    // we reset memory on reset
    .mem_clear    (reset),

    .max_delay    (mem_max_delay),

    .memreq_val   (memreq_val),
    .memreq_rdy   (memreq_rdy),
    .memreq_msg   (memreq_msg),

    .memresp_val  (memresp_val),
    .memresp_rdy  (memresp_rdy),
    .memresp_msg  (memresp_msg)
  );

  // Test sink

  logic        sink_done;

  vc_TestRandDelaySink#(c_cache_resp_nbits) sink
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),
    .done       (sink_done)
  );

  // Done when both source and sink are done for both ports

  assign done = src_done & sink_done;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  vc_MemReqMsgTrace#(c_cache_opaque_nbits, c_cache_addr_nbits, c_cache_data_nbits) cachereq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (src_val),
    .rdy   (src_rdy),
    .msg   (src_msg)
  );

  vc_MemRespMsgTrace#(c_cache_opaque_nbits, c_cache_data_nbits) cacheresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .msg   (sink_msg)
  );

  vc_MemReqMsgTrace#(c_mem_opaque_nbits, c_mem_addr_nbits, c_mem_data_nbits) memreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memreq_val),
    .rdy   (memreq_rdy),
    .msg   (memreq_msg)
  );

  vc_MemRespMsgTrace#(c_mem_opaque_nbits, c_mem_data_nbits) memresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memresp_val),
    .rdy   (memresp_rdy),
    .msg   (memresp_msg)
  );

  `VC_TRACE_BEGIN
  begin

    cachereq_trace.trace( trace_str );

    vc_trace.append_str( trace_str, " > " );

    cache.trace( trace_str );

    vc_trace.append_str( trace_str, " " );

    memreq_trace.trace( trace_str );

    vc_trace.append_str( trace_str, " | " );

    memresp_trace.trace( trace_str );

    vc_trace.append_str( trace_str, " > " );

    cacheresp_trace.trace( trace_str );

  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `LAB3_MEM_IMPL_STR )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  logic        th_reset = 1'b1;
  logic        th_mem_clear;
  logic [31:0] th_src_max_delay;
  logic [31:0] th_mem_max_delay;
  logic [31:0] th_sink_max_delay;
  logic        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  //------------------------------------------------------------------------
  // Helper task to initialize source/sink delays
  //------------------------------------------------------------------------

  task init_test_case
  (
    input logic [31:0] src_max_delay,
    input logic [31:0] mem_max_delay,
    input logic [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_sink_max_delay = sink_max_delay;
    // reset the index for test source/sink
    th_index = 32'b0;

    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;
  end
  endtask

  //----------------------------------------------------------------------
  // task to load to test memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input logic [31:0]  addr,
    input logic [127:0] data
  );
  begin
    th.test_mem.mem.m[ addr >> 4 ] = data;
  end
  endtask

  //------------------------------------------------------------------------
  // Helper task to initalize source/sink
  //------------------------------------------------------------------------

  logic [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] th_port_memreq;
  logic [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port_memresp;
  // index into the next test src/sink index
  logic [31:0] th_index = 32'b0;

  task init_port
  (
    //input logic [1023:0] index,

    input logic [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   memreq_type,
    input logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] memreq_opaque,
    input logic [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   memreq_addr,
    input logic [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    memreq_len,
    input logic [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   memreq_data,

    input logic [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]     memresp_type,
    input logic [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0]   memresp_opaque,
    input logic [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]      memresp_len,
    input logic [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]     memresp_data
  );
  begin
    th_port_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,32,32)]   = memreq_type;
    th_port_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,32,32)] = memreq_opaque;
    th_port_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,32,32)]   = memreq_addr;
    th_port_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,32,32)]    = memreq_len;
    th_port_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,32,32)]   = memreq_data;

    th_port_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src.src.m[th_index]   = th_port_memreq;
    th.sink.sink.m[th_index] = th_port_memresp;

    // increment the index for the next call to init_port
    th_index = th_index + 1'b1;

    // the following is to prevent previous test cases to "leak" into the
    // next cases
    th.src.src.m[th_index]   = 'hx;
    th.sink.sink.m[th_index] = 'hx;
  end
  endtask

  // Helper local params

  localparam c_req_rd  = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam c_req_wr  = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam c_req_wn  = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam c_req_ad  = `VC_MEM_REQ_MSG_TYPE_AMO_ADD;
  localparam c_req_an  = `VC_MEM_REQ_MSG_TYPE_AMO_AND;
  localparam c_req_ao  = `VC_MEM_REQ_MSG_TYPE_AMO_OR;

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_wn = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;
  localparam c_resp_ad = `VC_MEM_RESP_MSG_TYPE_AMO_ADD;
  localparam c_resp_an = `VC_MEM_RESP_MSG_TYPE_AMO_AND;
  localparam c_resp_ao = `VC_MEM_RESP_MSG_TYPE_AMO_OR;

  // Helper task to run test

  task run_test;
  begin
    while ( !th_done && (th.vc_trace.cycles < 5000) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // Include Python-generated input datasets
  //----------------------------------------------------------------------

  `include "lab3-mem-gen-input_random-writeread.py.v"

  `include "lab3-mem-gen-input_random.py.v"

  `include "lab3-mem-gen-input_ustride.py.v"

  `include "lab3-mem-gen-input_stride2.py.v"

  `include "lab3-mem-gen-input_stride4.py.v"

  `include "lab3-mem-gen-input_shared.py.v"

  `include "lab3-mem-gen-input_ustride-shared.py.v"

  `include "lab3-mem-gen-input_loop-2d.py.v"

  `include "lab3-mem-gen-input_loop-3d.py.v"

  //----------------------------------------------------------------------
  // Ad-hoc test: init loads one word
  //----------------------------------------------------------------------

  // This test has been commented out and can be uncommented as
  // a first ad-hoc test case for the init transaction. Note that
  // ad-hoc tests may not work on the functional model.

  `VC_TEST_CASE_BEGIN( 1, "init - loading one word in the 0th cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    //// Initialize Port

    ////         ------------- memory request ----------------  --------- memory response ----------
    ////         type      opaque addr          len   data          type       opaque len   data

    //init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'he110341d, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    //run_test;

    //if ( th.done )
    //  `VC_ASSERT( th.cache.dpath.data_array.mem[0][31:0] == 32'he110341d );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Tests
  //----------------------------------------------------------------------

  // insert basic test cases here!

  //----------------------------------------------------------------------
  // Directed Tests
  //----------------------------------------------------------------------

  // insert directed test cases here!

  //----------------------------------------------------------------------
  // Random Tests
  //----------------------------------------------------------------------

  // insert random test cases from scripts here!

  //----------------------------------------------------------------------
  // Pattern Tests
  //----------------------------------------------------------------------

  // insert pattern test cases here! You can use these tasks:
  // - init_random_writeread;
  // - init_random;
  // - init_ustride;
  // - init_stride2;
  // - init_stride4;
  // - init_shared;
  // - init_ustride_shared;
  // - init_loop_2d;
  // - init_loop_3d;


  `VC_TEST_SUITE_END
endmodule
