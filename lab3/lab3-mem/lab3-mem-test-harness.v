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
  localparam c_req_in  = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam c_req_ad  = `VC_MEM_REQ_MSG_TYPE_AMO_ADD;
  localparam c_req_an  = `VC_MEM_REQ_MSG_TYPE_AMO_AND;
  localparam c_req_ao  = `VC_MEM_REQ_MSG_TYPE_AMO_OR;

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_in = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;
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
  // Directed Test Cases
  //----------------------------------------------------------------------


  //----------------------------------------------------------------------
  // Basic Test Case #1: Read Hit Path (clean)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test case 1: read hit path (clean)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_in, 8'h00, 32'h00000004, 2'd0, 32'h000b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000004
    init_port( c_req_in, 8'h00, 32'h00000008, 2'd0, 32'h00000c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000008
    init_port( c_req_in, 8'h00, 32'h0000000c, 2'd0, 32'h0000000d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x0000000c
    init_port( c_req_in, 8'h00, 32'h00000010, 2'd0, 32'h0000000e, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000010

    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d ); // read  word  0x00000000
    init_port( c_req_rd, 8'h01, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h000b0c0d ); // read  word  0x00000004
    init_port( c_req_rd, 8'h01, 32'h00000008, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000c0d ); // read  word  0x00000008
    init_port( c_req_rd, 8'h01, 32'h0000000c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000d ); // read  word  0x0000000c
    init_port( c_req_rd, 8'h01, 32'h00000010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000e ); // read  word  0x0000000c


    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Test Case #2: Write Hit Path (both) + Read Hit Path (dirty)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test case 2: write hit path (both) + read hit path (dirty)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000020, 2'd0, 32'habcdef00, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // init  word  0x00000020
    init_port( c_req_in, 8'h00, 32'h00000030, 2'd0, 32'h00000fab, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000030
    init_port( c_req_in, 8'h00, 32'h00000034, 2'd0, 32'h10000001, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000034
    init_port( c_req_wr, 8'h01, 32'h00000038, 2'd0, 32'h00000002, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000038
    init_port( c_req_wr, 8'h01, 32'h0000003c, 2'd0, 32'h00000003, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x0000003c

    init_port( c_req_rd, 8'h01, 32'h00000020, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'habcdef00 );

    init_port( c_req_rd, 8'h01, 32'h00000030, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000fab );
    init_port( c_req_wr, 8'h01, 32'h00000030, 2'd0, 32'h00000004, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000030
    init_port( c_req_rd, 8'h01, 32'h00000030, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000004 );

    init_port( c_req_rd, 8'h01, 32'h00000038, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000002 );
    init_port( c_req_wr, 8'h01, 32'h00000038, 2'd0, 32'h0000000f, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000038
    init_port( c_req_rd, 8'h01, 32'h00000038, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000f );

    init_port( c_req_rd, 8'h01, 32'h00000034, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h10000001 );
    init_port( c_req_rd, 8'h01, 32'h0000003c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000003 );    

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Test Case #3: Read Miss Path (clean)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test case 3: read miss path (clean)" )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00000100, 128'h00000004000000030000000200000001 );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_in, 8'h00, 32'h00000004, 2'd0, 32'h0a000000, c_resp_in, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000004
    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d );

    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_rd, 8'h01, 32'h00000104, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000002 );
    init_port( c_req_rd, 8'h01, 32'h00000108, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000003 );
    init_port( c_req_rd, 8'h01, 32'h0000010c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000004 );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Test Case #4: Read Miss Path (dirty)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "basic test case 4: read miss path (dirty)" )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00000100, 128'h00000004000000030000000200000001 );


    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_in, 8'h00, 32'h00000004, 2'd0, 32'h0a000000, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_wr, 8'h01, 32'h00000008, 2'd0, 32'h12345678, c_resp_wr, 8'h01, 2'd0, 32'h???????? );

    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d );
    init_port( c_req_rd, 8'h01, 32'h00000008, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h12345678 );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Test Case #5: Write Miss Path (clean)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "basic test case 5: write miss path (clean)" )
  begin
    init_test_case( 0, 0, 0 );


    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_in, 8'h00, 32'h00000004, 2'd0, 32'h0a000000, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 

    init_port( c_req_wr, 8'h01, 32'h00000100, 2'd0, 32'h00000001, c_resp_wr, 8'h01, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h01, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Basic Test Case #6: Write Miss Path (dirty)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "basic test case 6: Write miss path (dirty)" )
  begin
    init_test_case( 0, 0, 0 );


    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_in, 8'h00, 32'h00000004, 2'd0, 32'h0a000000, c_resp_in, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'h00111000, c_resp_wr, 8'h01, 2'd0, 32'h???????? );

    init_port( c_req_wr, 8'h01, 32'h00000100, 2'd0, 32'h00000001, c_resp_wr, 8'h01, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00111000 );
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // ALternative Test Case #1: Conflict Misses
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "alternative test case 1: conflict misses" )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00000100, 128'h00000004000000030000000200000001 );
    load_mem( 32'h00000200, 128'h00000008000000070000000600000005 );
    load_mem( 32'h00000300, 128'h0000000d0000000c0000000b0000000a );
    load_mem( 32'h00000400, 128'h0000000f0000000e0000000d0000000c );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00000004, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); 
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d ); 
    init_port( c_req_rd, 8'h01, 32'h00000200, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000005 ); 
    init_port( c_req_rd, 8'h01, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000001 );
    init_port( c_req_rd, 8'h01, 32'h00000300, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000a ); 
    init_port( c_req_rd, 8'h01, 32'h00000200, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00000005 );
    init_port( c_req_rd, 8'h01, 32'h00000400, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000c ); 
    init_port( c_req_rd, 8'h01, 32'h00000300, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0000000a );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // ALternative Test Case #2: LRU Replacement Policy
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "alternative test case 2: LRU replacement policy part 1. Uncomment to run properly. //BASELINE SHOULD FAIL." )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00000000, 128'h00000004000000030000000200000001 );
    load_mem( 32'h00000100, 128'h00000004000000030000000200000001 );
    load_mem( 32'h00000200, 128'h00000004000000030000000200000001 );


    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? );       
    //init_port( c_req_rd, 8'h00, 32'h00000100, 2'd0, 32'h????????, c_resp_rd, 8'h00, 2'd0, 32'h00000001 ); 

    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d );       // read miss to way 1

    run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 9, "alternative test case 2: LRU replacement policy part 2. Uncomment to run properly. //Both SHOULD FAIL." )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00000000, 128'h00000004000000030000000200000001 );
    load_mem( 32'h00000100, 128'h00000004000000030000000200000001 );
    load_mem( 32'h00000200, 128'h00000004000000030000000200000001 );


    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_in, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_in, 8'h00, 2'd0, 32'h???????? );       
    //init_port( c_req_rd, 8'h00, 32'h00000100, 2'd0, 32'h????????, c_resp_rd, 8'h00, 2'd0, 32'h00000001 );
    //init_port( c_req_rd, 8'h00, 32'h00000200, 2'd0, 32'h????????, c_resp_rd, 8'h00, 2'd0, 32'h00000001 ); 

    init_port( c_req_rd, 8'h01, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h0a0b0c0d );       // read miss to way 1

    run_test;
  end
  `VC_TEST_CASE_END

  
  //Test 10
  `VC_TEST_CASE_BEGIN( 10, "Current Bug Catch test" )
  begin
    init_test_case( 0, 0, 0 );
    load_mem( 32'h00001000, 128'h00000003_00000002_00000001_00000000 );
    load_mem( 32'h00001010, 128'h00000007_00000006_00000005_00000004 );
    load_mem( 32'h00001020, 128'h0000000b_0000000a_00000009_00000008 );


    init_port( c_req_rd, 8'h00, 32'h00001000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000000 );
    init_port( c_req_rd, 8'h00, 32'h00001010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000004 );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // RANDOM TEST CASES
  //----------------------------------------------------------------------
  
  // Random Test Case #1: ????
  `VC_TEST_CASE_BEGIN( 11, "Random Test Case #1: ----" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    //Code generated by Python file: ubmark-...
    load_mem( 32'h00001000, 128'h000006d1_00000997_00000784_0000004e );
    load_mem( 32'h00001010, 128'h00000f72_00000a0c_00000ba4_000009cc );
    load_mem( 32'h00001020, 128'h00000b91_00000ab2_000005d6_0000054e );
    load_mem( 32'h00001030, 128'h00000448_00000821_0000061a_00000d24 );
    load_mem( 32'h00001040, 128'h0000050b_000002d7_00000f91_00000fe2 );
    load_mem( 32'h00001050, 128'h0000094d_0000092d_00000696_0000022d );
    load_mem( 32'h00001060, 128'h0000001f_00000add_00001000_0000021a );
    load_mem( 32'h00001070, 128'h00000f06_000002d6_00000b03_00000645 );
    load_mem( 32'h00001080, 128'h00000633_00000558_00000b5e_00000295 );
    load_mem( 32'h00001090, 128'h00000387_00000d2c_00000908_00000712 );
    load_mem( 32'h000010a0, 128'h00000311_000007fd_00000ed0_0000015a );
    load_mem( 32'h000010b0, 128'h00000b14_00000978_00000473_000000ce );
    load_mem( 32'h000010c0, 128'h00000aa6_000000b0_00000b15_000007a2 );
    load_mem( 32'h000010d0, 128'h00000706_00000207_000004e8_000003d1 );
    load_mem( 32'h000010e0, 128'h0000094e_00000601_00000291_0000061e );
    load_mem( 32'h000010f0, 128'h00000887_0000046d_00000f95_00000547 );
    load_mem( 32'h00001100, 128'h00000b59_00000c2f_000000da_00000f82 );
    load_mem( 32'h00001110, 128'h000001c0_000003a7_000005a8_00000870 );
    load_mem( 32'h00001120, 128'h000009dd_0000074a_00000d8a_00000fca );
    load_mem( 32'h00001130, 128'h0000076b_00000be2_00000f45_00000ecf );
    load_mem( 32'h00001140, 128'h000005d2_0000027b_00000626_00000fba );
    load_mem( 32'h00001150, 128'h00000bba_000002fc_00000e88_0000038a );
    load_mem( 32'h00001160, 128'h00000fcb_000003e8_0000061b_00000d63 );
    load_mem( 32'h00001170, 128'h00000b67_00000bbf_000005c0_00000f8d );
    load_mem( 32'h00001180, 128'h0000092d_0000097d_000000ea_00000a02 );
    init_port( c_req_rd, 8'h00, 32'h00001000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000004e );
    init_port( c_req_rd, 8'h00, 32'h00001004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000784 );
    init_port( c_req_rd, 8'h00, 32'h00001008, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000997 );
    init_port( c_req_rd, 8'h00, 32'h0000100c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000006d1 );
    init_port( c_req_rd, 8'h00, 32'h00001010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000009cc );
    init_port( c_req_rd, 8'h00, 32'h00001014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000ba4 );
    init_port( c_req_rd, 8'h00, 32'h00001018, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000a0c );
    init_port( c_req_rd, 8'h00, 32'h0000101c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f72 );
    init_port( c_req_rd, 8'h00, 32'h00001020, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000054e );
    init_port( c_req_rd, 8'h00, 32'h00001024, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000005d6 );
    init_port( c_req_rd, 8'h00, 32'h00001028, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000ab2 );
    init_port( c_req_rd, 8'h00, 32'h0000102c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b91 );
    init_port( c_req_rd, 8'h00, 32'h00001030, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000d24 );
    init_port( c_req_rd, 8'h00, 32'h00001034, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000061a );
    init_port( c_req_rd, 8'h00, 32'h00001038, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000821 );
    init_port( c_req_rd, 8'h00, 32'h0000103c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000448 );
    init_port( c_req_rd, 8'h00, 32'h00001040, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000fe2 );
    init_port( c_req_rd, 8'h00, 32'h00001044, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f91 );
    init_port( c_req_rd, 8'h00, 32'h00001048, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000002d7 );
    init_port( c_req_rd, 8'h00, 32'h0000104c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000050b );
    init_port( c_req_rd, 8'h00, 32'h00001050, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000022d );
    init_port( c_req_rd, 8'h00, 32'h00001054, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000696 );
    init_port( c_req_rd, 8'h00, 32'h00001058, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000092d );
    init_port( c_req_rd, 8'h00, 32'h0000105c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000094d );
    init_port( c_req_rd, 8'h00, 32'h00001060, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000021a );
    init_port( c_req_rd, 8'h00, 32'h00001064, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00001000 );
    init_port( c_req_rd, 8'h00, 32'h00001068, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000add );
    init_port( c_req_rd, 8'h00, 32'h0000106c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000001f );
    init_port( c_req_rd, 8'h00, 32'h00001070, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000645 );
    init_port( c_req_rd, 8'h00, 32'h00001074, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b03 );
    init_port( c_req_rd, 8'h00, 32'h00001078, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000002d6 );
    init_port( c_req_rd, 8'h00, 32'h0000107c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f06 );
    init_port( c_req_rd, 8'h00, 32'h00001080, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000295 );
    init_port( c_req_rd, 8'h00, 32'h00001084, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b5e );
    init_port( c_req_rd, 8'h00, 32'h00001088, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000558 );
    init_port( c_req_rd, 8'h00, 32'h0000108c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000633 );
    init_port( c_req_rd, 8'h00, 32'h00001090, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000712 );
    init_port( c_req_rd, 8'h00, 32'h00001094, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000908 );
    init_port( c_req_rd, 8'h00, 32'h00001098, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000d2c );
    init_port( c_req_rd, 8'h00, 32'h0000109c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000387 );
    init_port( c_req_rd, 8'h00, 32'h000010a0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000015a );
    init_port( c_req_rd, 8'h00, 32'h000010a4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000ed0 );
    init_port( c_req_rd, 8'h00, 32'h000010a8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000007fd );
    init_port( c_req_rd, 8'h00, 32'h000010ac, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000311 );
    init_port( c_req_rd, 8'h00, 32'h000010b0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000000ce );
    init_port( c_req_rd, 8'h00, 32'h000010b4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000473 );
    init_port( c_req_rd, 8'h00, 32'h000010b8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000978 );
    init_port( c_req_rd, 8'h00, 32'h000010bc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b14 );
    init_port( c_req_rd, 8'h00, 32'h000010c0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000007a2 );
    init_port( c_req_rd, 8'h00, 32'h000010c4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b15 );
    init_port( c_req_rd, 8'h00, 32'h000010c8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000000b0 );
    init_port( c_req_rd, 8'h00, 32'h000010cc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000aa6 );
    init_port( c_req_rd, 8'h00, 32'h000010d0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000003d1 );
    init_port( c_req_rd, 8'h00, 32'h000010d4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000004e8 );
    init_port( c_req_rd, 8'h00, 32'h000010d8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000207 );
    init_port( c_req_rd, 8'h00, 32'h000010dc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000706 );
    init_port( c_req_rd, 8'h00, 32'h000010e0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000061e );
    init_port( c_req_rd, 8'h00, 32'h000010e4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000291 );
    init_port( c_req_rd, 8'h00, 32'h000010e8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000601 );
    init_port( c_req_rd, 8'h00, 32'h000010ec, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000094e );
    init_port( c_req_rd, 8'h00, 32'h000010f0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000547 );
    init_port( c_req_rd, 8'h00, 32'h000010f4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f95 );
    init_port( c_req_rd, 8'h00, 32'h000010f8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000046d );
    init_port( c_req_rd, 8'h00, 32'h000010fc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000887 );
    init_port( c_req_rd, 8'h00, 32'h00001100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f82 );
    init_port( c_req_rd, 8'h00, 32'h00001104, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000000da );
    init_port( c_req_rd, 8'h00, 32'h00001108, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000c2f );
    init_port( c_req_rd, 8'h00, 32'h0000110c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b59 );
    init_port( c_req_rd, 8'h00, 32'h00001110, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000870 );
    init_port( c_req_rd, 8'h00, 32'h00001114, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000005a8 );
    init_port( c_req_rd, 8'h00, 32'h00001118, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000003a7 );
    init_port( c_req_rd, 8'h00, 32'h0000111c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000001c0 );
    init_port( c_req_rd, 8'h00, 32'h00001120, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000fca );
    init_port( c_req_rd, 8'h00, 32'h00001124, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000d8a );
    init_port( c_req_rd, 8'h00, 32'h00001128, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000074a );
    init_port( c_req_rd, 8'h00, 32'h0000112c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000009dd );
    init_port( c_req_rd, 8'h00, 32'h00001130, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000ecf );
    init_port( c_req_rd, 8'h00, 32'h00001134, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f45 );
    init_port( c_req_rd, 8'h00, 32'h00001138, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000be2 );
    init_port( c_req_rd, 8'h00, 32'h0000113c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000076b );
    init_port( c_req_rd, 8'h00, 32'h00001140, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000fba );
    init_port( c_req_rd, 8'h00, 32'h00001144, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000626 );
    init_port( c_req_rd, 8'h00, 32'h00001148, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000027b );
    init_port( c_req_rd, 8'h00, 32'h0000114c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000005d2 );
    init_port( c_req_rd, 8'h00, 32'h00001150, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000038a );
    init_port( c_req_rd, 8'h00, 32'h00001154, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000e88 );
    init_port( c_req_rd, 8'h00, 32'h00001158, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000002fc );
    init_port( c_req_rd, 8'h00, 32'h0000115c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000bba );
    init_port( c_req_rd, 8'h00, 32'h00001160, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000d63 );
    init_port( c_req_rd, 8'h00, 32'h00001164, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000061b );
    init_port( c_req_rd, 8'h00, 32'h00001168, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000003e8 );
    init_port( c_req_rd, 8'h00, 32'h0000116c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000fcb );
    init_port( c_req_rd, 8'h00, 32'h00001170, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000f8d );
    init_port( c_req_rd, 8'h00, 32'h00001174, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000005c0 );
    init_port( c_req_rd, 8'h00, 32'h00001178, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000bbf );
    init_port( c_req_rd, 8'h00, 32'h0000117c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000b67 );
    init_port( c_req_rd, 8'h00, 32'h00001180, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h00000a02 );
    init_port( c_req_rd, 8'h00, 32'h00001184, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h000000ea );
    init_port( c_req_rd, 8'h00, 32'h00001188, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000097d );
    init_port( c_req_rd, 8'h00, 32'h0000118c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0000092d );

    run_test;
  end
  `VC_TEST_CASE_END


  
  // Random Test Case #2: ????
  `VC_TEST_CASE_BEGIN( 12, "Random Test Case #2: ----" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request --------------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    //Code generated by Python file: ubmark-randtest-suite.py
    load_mem( 32'h00001000, 128'h6d146dfc_996ab63d_7839d4fc_04e5f14d );
    load_mem( 32'h00001010, 128'hf72041ee_a0c394ff_ba43a338_9cb87fec );
    load_mem( 32'h00001020, 128'hb910141d_ab1f1cad_5d604596_54ded30c );
    load_mem( 32'h00001030, 128'h4486fe08_820d4635_619ed116_d23e615b );
    load_mem( 32'h00001040, 128'h50ae112c_2d75dad0_f9072dc8_fe113708 );
    load_mem( 32'h00001050, 128'h94ca742f_92cf8b1d_6968b94a_22d3180f );
    load_mem( 32'h00001060, 128'h01f2a824_adc68830_fffd2abd_21a4f23e );
    load_mem( 32'h00001070, 128'hf0511869_2d624733_b0289bb1_6454ce15 );
    load_mem( 32'h00001080, 128'h63380179_557cea2e_b5e2742f_294f608b );
    load_mem( 32'h00001090, 128'h387ba072_d2b5d231_9080d428_711b4ebf );
    load_mem( 32'h000010a0, 128'h310fbbc0_7fccbbfd_ecf4842a_15ab548e );
    load_mem( 32'h000010b0, 128'hb139c4f7_977be8d1_473a6c99_0cdfe464 );
    load_mem( 32'h000010c0, 128'haa5a158e_0b02af24_b14a97ae_7a20f9eb );
    load_mem( 32'h000010d0, 128'h706336de_20736bbd_4e86c0dd_3d1b0664 );
    load_mem( 32'h000010e0, 128'h94e06c61_60192c75_29119703_61e648d6 );
    load_mem( 32'h000010f0, 128'h88706d25_46d0fd34_f94f7d8d_54797aa5 );
    load_mem( 32'h00001100, 128'hb591a19a_c2ec557b_0da6cbd8_f816cda3 );
    load_mem( 32'h00001110, 128'h1bff01ed_3a6c692f_5a8551a4_8700640b );
    load_mem( 32'h00001120, 128'h9dd55b4f_74a3f09c_d8a0a06e_fc91174d );
    load_mem( 32'h00001130, 128'h76aaeb91_be1f3be7_f44beefa_ecef67f7 );
    load_mem( 32'h00001140, 128'h5d25fe10_27b2cb3a_625b2744_fb91e5c0 );
    load_mem( 32'h00001150, 128'hbb953e3b_2fc1891e_e87c8c1a_389e6e0a );
    load_mem( 32'h00001160, 128'hfca6be2a_3e7cc2a2_61aaf5b5_d62e5e14 );
    load_mem( 32'h00001170, 128'hb672c4b7_bbf28159_5c03065e_f8cbabba );
    load_mem( 32'h00001180, 128'h92d647fe_97c907b1_0eaf0376_a0256412 );
    init_port( c_req_wr, 8'h00, 32'h000010d4, 2'd0, 32'h92648f0b, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001124, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hd8a0a06e );
    init_port( c_req_rd, 8'h00, 32'h00001150, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h389e6e0a );
    init_port( c_req_rd, 8'h00, 32'h000010a0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h15ab548e );
    init_port( c_req_wr, 8'h00, 32'h00001128, 2'd0, 32'ha551b966, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000115c, 2'd0, 32'h62ecbaec, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h000010a0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h15ab548e );
    init_port( c_req_wr, 8'h00, 32'h00001134, 2'd0, 32'hcbd1e068, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h0000113c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h76aaeb91 );
    init_port( c_req_wr, 8'h00, 32'h0000106c, 2'd0, 32'h8953181d, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000108c, 2'd0, 32'he9d0b317, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h000010a4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hecf4842a );
    init_port( c_req_rd, 8'h00, 32'h000010fc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h88706d25 );
    init_port( c_req_rd, 8'h00, 32'h00001158, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h2fc1891e );
    init_port( c_req_wr, 8'h00, 32'h000010a8, 2'd0, 32'hb9e3b30f, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h0000116c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hfca6be2a );
    init_port( c_req_wr, 8'h00, 32'h0000117c, 2'd0, 32'hedabd8e5, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001150, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h389e6e0a );
    init_port( c_req_wr, 8'h00, 32'h00001114, 2'd0, 32'h81a886bb, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001044, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hf9072dc8 );
    init_port( c_req_rd, 8'h00, 32'h000010a8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hb9e3b30f );
    init_port( c_req_rd, 8'h00, 32'h00001104, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0da6cbd8 );
    init_port( c_req_rd, 8'h00, 32'h000010bc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hb139c4f7 );
    init_port( c_req_wr, 8'h00, 32'h000010d8, 2'd0, 32'h8528cfd2, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h0000107c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hf0511869 );
    init_port( c_req_wr, 8'h00, 32'h00001144, 2'd0, 32'h08640af5, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001180, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'ha0256412 );
    init_port( c_req_rd, 8'h00, 32'h000010c4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hb14a97ae );
    init_port( c_req_rd, 8'h00, 32'h00001070, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h6454ce15 );
    init_port( c_req_rd, 8'h00, 32'h0000118c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h92d647fe );
    init_port( c_req_wr, 8'h00, 32'h00001024, 2'd0, 32'ha0d75158, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000117c, 2'd0, 32'h263db6e3, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001094, 2'd0, 32'he7826ff6, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001008, 2'd0, 32'h93125f15, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001130, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hecef67f7 );
    init_port( c_req_rd, 8'h00, 32'h000010c0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h7a20f9eb );
    init_port( c_req_rd, 8'h00, 32'h00001108, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hc2ec557b );
    init_port( c_req_wr, 8'h00, 32'h00001138, 2'd0, 32'h11818e7d, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001074, 2'd0, 32'h613f8190, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h0000113c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h76aaeb91 );
    init_port( c_req_rd, 8'h00, 32'h000010f8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h46d0fd34 );
    init_port( c_req_wr, 8'h00, 32'h00001158, 2'd0, 32'h73308d47, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001040, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hfe113708 );
    init_port( c_req_rd, 8'h00, 32'h00001114, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h81a886bb );
    init_port( c_req_wr, 8'h00, 32'h00001128, 2'd0, 32'h17c6d0a0, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001074, 2'd0, 32'hf303389e, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001014, 2'd0, 32'hcf09e85c, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001018, 2'd0, 32'hac6b3a74, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001024, 2'd0, 32'h1ba54374, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h000010e0, 2'd0, 32'hb4ebbfd9, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000107c, 2'd0, 32'h5f5de5c8, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001048, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h2d75dad0 );
    init_port( c_req_rd, 8'h00, 32'h00001064, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hfffd2abd );
    init_port( c_req_wr, 8'h00, 32'h000010e0, 2'd0, 32'h83af6b93, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001060, 2'd0, 32'h9eef7d86, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001044, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hf9072dc8 );
    init_port( c_req_wr, 8'h00, 32'h0000111c, 2'd0, 32'h6c43bb6d, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001030, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hd23e615b );
    init_port( c_req_rd, 8'h00, 32'h00001170, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hf8cbabba );
    init_port( c_req_wr, 8'h00, 32'h00001078, 2'd0, 32'h0dec730e, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001010, 2'd0, 32'h463d090b, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h0000100c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h6d146dfc );
    init_port( c_req_rd, 8'h00, 32'h00001178, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hbbf28159 );
    init_port( c_req_rd, 8'h00, 32'h00001138, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h11818e7d );
    init_port( c_req_wr, 8'h00, 32'h000010dc, 2'd0, 32'h16017b21, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001148, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h27b2cb3a );
    init_port( c_req_wr, 8'h00, 32'h000010e4, 2'd0, 32'hefab0a9a, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h000010d4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h92648f0b );
    init_port( c_req_rd, 8'h00, 32'h00001134, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hcbd1e068 );
    init_port( c_req_rd, 8'h00, 32'h000010cc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'haa5a158e );
    init_port( c_req_wr, 8'h00, 32'h00001120, 2'd0, 32'h11e7d237, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001148, 2'd0, 32'hcf7d9ae5, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h000010b4, 2'd0, 32'hce66f045, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000115c, 2'd0, 32'hdab4fc7c, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001050, 2'd0, 32'haddfe2e7, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hcf09e85c );
    init_port( c_req_rd, 8'h00, 32'h00001170, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hf8cbabba );
    init_port( c_req_rd, 8'h00, 32'h000010c4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hb14a97ae );
    init_port( c_req_rd, 8'h00, 32'h000010dc, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h16017b21 );
    init_port( c_req_wr, 8'h00, 32'h00001070, 2'd0, 32'h346ec534, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001140, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hfb91e5c0 );
    init_port( c_req_rd, 8'h00, 32'h000010f0, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h54797aa5 );
    init_port( c_req_wr, 8'h00, 32'h000010d0, 2'd0, 32'h7f2919a7, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h000010a4, 2'd0, 32'hdaa48261, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000111c, 2'd0, 32'h237d74c5, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h000010f0, 2'd0, 32'h1f2a9550, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h463d090b );
    init_port( c_req_rd, 8'h00, 32'h000010e4, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hefab0a9a );
    init_port( c_req_rd, 8'h00, 32'h00001088, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h557cea2e );
    init_port( c_req_rd, 8'h00, 32'h00001098, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hd2b5d231 );
    init_port( c_req_wr, 8'h00, 32'h000010b0, 2'd0, 32'h3f58acf3, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h000010d8, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h8528cfd2 );
    init_port( c_req_rd, 8'h00, 32'h00001160, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hd62e5e14 );
    init_port( c_req_wr, 8'h00, 32'h00001004, 2'd0, 32'h6c4225c7, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00001180, 2'd0, 32'h70829e02, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000109c, 2'd0, 32'h929a4ac3, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h0000101c, 2'd0, 32'hb908ff7e, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_rd, 8'h00, 32'h00001178, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hbbf28159 );
    init_port( c_req_wr, 8'h00, 32'h00001088, 2'd0, 32'h0713df2a, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h000010b0, 2'd0, 32'hfbe40a94, c_resp_wr, 8'h00, 2'd0, 32'h???????? );

    run_test;
  end
  `VC_TEST_CASE_END



  //TESTING SUITE DONE
  `VC_TEST_SUITE_END

endmodule

