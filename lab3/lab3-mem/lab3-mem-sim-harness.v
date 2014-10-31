//========================================================================
// Cache Simulator Harness
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
`include "vc-TestDelay.v"
`include "vc-test.v"
`include "vc-trace.v"

`include "vc-mem-msgs.v"

`include "vc-TestRandDelayMem_1port.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input  logic        clk,
  input  logic        reset,
  input  logic        mem_clear,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] mem_max_delay,
  input  logic [31:0] mem_fixed_delay,
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

  // to be able to determine if we have a refill or evict, we snoop the
  // memory message to see what type it is
  localparam c_mem_req_type_nbits  = `VC_MEM_REQ_MSG_TYPE_NBITS(
                    c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits);

  logic [c_mem_req_type_nbits-1:0] memreq_type;
  assign memreq_type = memreq_msg[ `VC_MEM_REQ_MSG_TYPE_FIELD(
                  c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits) ];

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
  // Initialize the delay unit to force fixed delay in the memory
  //----------------------------------------------------------------------

  logic                          memreq_delay_val;
  logic                          memreq_delay_rdy;
  logic [c_mem_req_nbits-1:0]    memreq_delay_msg;

  vc_TestDelay#(c_mem_req_nbits) memreq_delay
  (
    .clk       (clk),
    .reset     (reset),

    .delay_amt (mem_fixed_delay),

    .in_val    (memreq_val),
    .in_rdy    (memreq_rdy),
    .in_msg    (memreq_msg),

    .out_val   (memreq_delay_val),
    .out_rdy   (memreq_delay_rdy),
    .out_msg   (memreq_delay_msg)
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

    .memreq_val   (memreq_delay_val),
    .memreq_rdy   (memreq_delay_rdy),
    .memreq_msg   (memreq_delay_msg),

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
// Simulation driver
//------------------------------------------------------------------------

module top;


  //----------------------------------------------------------------------
  // Process command line flags
  //----------------------------------------------------------------------

  logic [(512<<3)-1:0] input_dataset;
  logic [(512<<3)-1:0] vcd_dump_file_name;
  integer            stats_en = 0;
  integer            verify_en = 0;
  integer            max_cycles;

  initial begin

    // Input dataset

    if ( !$value$plusargs( "input=%s", input_dataset ) ) begin
      // default dataset is none
      input_dataset = "";
    end

    // Maximum cycles

    if ( !$value$plusargs( "max-cycles=%d", max_cycles ) ) begin
      max_cycles = 10000;
    end

    // VCD dumping

    if ( $value$plusargs( "dump-vcd=%s", vcd_dump_file_name ) ) begin
      $dumpfile(vcd_dump_file_name);
      $dumpvars;
    end

    // Output stats

    if ( $test$plusargs( "stats" ) ) begin
      stats_en = 1;
    end

    // Enable verify

    if ( $test$plusargs( "verify" ) ) begin
      verify_en = 1;
    end

    // Usage message

    if ( $test$plusargs( "help" ) ) begin
      $display( "" );
      $display( " lab3-mem-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +input=<dataset>      : {loop-1d,loop-2d,loop-3d}" );
      $display( "   +max-cycles=<int>     : max cycles to wait until done" );
      $display( "   +trace=<int>          : 1 turns on line tracing" );
      $display( "   +dump-vcd=<file-name> : dump VCD to given file name" );
      $display( "   +stats                : display statistics" );
      $display( "   +verify               : verify output" );
      $display( "" );
      $finish;
    end

  end

  //----------------------------------------------------------------------
  // Generate clock
  //----------------------------------------------------------------------

  logic clk = 1'b1;
  always #5 clk = ~clk;

  //----------------------------------------------------------------------
  // Instantiate the harness
  //----------------------------------------------------------------------

  logic        th_reset = 1'b1;
  logic        th_mem_clear;
  logic [31:0] th_src_max_delay;
  logic [31:0] th_mem_max_delay;
  logic [31:0] th_mem_fixed_delay;
  logic [31:0] th_sink_max_delay;
  logic        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .mem_fixed_delay(th_mem_fixed_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  //------------------------------------------------------------------------
  // Helper task to initialize source/sink delays
  //------------------------------------------------------------------------

  task init_delays
  (
    input logic [31:0] src_max_delay,
    input logic [31:0] mem_max_delay,
    input logic [31:0] mem_fixed_delay,
    input logic [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_mem_fixed_delay= mem_fixed_delay;
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

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_in = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;

  //----------------------------------------------------------------------
  // Drive the simulation
  //----------------------------------------------------------------------

  // number of cache accesses
  integer num_cache_acc = 0;
  // number of misses and hits in the cache
  integer num_misses    = 0;
  integer num_hits      = 0;
  integer num_evicts    = 0;
  integer num_refills   = 0;
  integer num_mem_acc   = 0;

  // mark if this current transaction is a miss
  integer xaction_miss = 0;

  initial begin

    #1;

    // we use a fixed delay of 20 cycles in the memory
    init_delays( 0, 0, 19, 0 );

    if          ( input_dataset == "loop-1d"   ) begin
      `include "lab3-mem-gen-input_loop-1d.py.v"
    end else if ( input_dataset == "loop-2d"   ) begin
      `include "lab3-mem-gen-input_loop-2d.py.v"
    end else if ( input_dataset == "loop-3d"   ) begin
      `include "lab3-mem-gen-input_loop-3d.py.v"
    end

    else begin
      $display( "" );
      $display( " ERROR: Unrecognized input dataset specified with +input! (%s)",
                            input_dataset );
      $display( "" );
      $finish_and_return(1);
    end

    // Reset signal

         th_reset = 1'b1;
    #20; th_reset = 1'b0;

    // Run the simulation

    while ( !th_done && (th.vc_trace.cycles < max_cycles) ) begin
      th.display_trace();
      // if the source could be sent, this is a valid cache access
      if ( th.src_val && th.src_rdy ) begin
        num_cache_acc = num_cache_acc + 1;
        // initially mark this transaction as a hit
        xaction_miss = 0;
      end

      if ( th.memreq_val && th.memreq_rdy ) begin
        // if we go to the main memory, then this transaction is a miss
        xaction_miss = 1;
        // snoop the memory request message and increment the refill/evict
        // counter accordingly
        num_mem_acc = num_mem_acc + 1;
        if ( th.memreq_type == `VC_MEM_REQ_MSG_TYPE_READ )
          num_refills = num_refills + 1;
        else
          num_evicts = num_evicts + 1;
      end

      if ( th.sink_val && th.sink_rdy ) begin
        // we increment the counters accordingly
        if ( xaction_miss )
          num_misses = num_misses + 1;
        else
          num_hits   = num_hits   + 1;
      end

      #10;
    end

    // Check that the simulation actually finished

    if ( !th_done ) begin
      $display( "" );
      $display( " ERROR: Simulation did not finish in time. Maybe increase" );
      $display( " the simulation time limit using the +max-cycles=<int>" );
      $display( " command line parameter?" );
      $display( "" );
      $finish_and_return(1);
    end

    // Output stats

    if ( stats_en ) begin
      $display( "num_cycles              = %0d", th.vc_trace.cycles );
      $display( "num_cache_accesses      = %0d", num_cache_acc      );
      $display( "num_hits                = %0d", num_hits           );
      $display( "num_misses              = %0d", num_misses         );
      $display( "miss_rate               = %f%%",
                                    100.0*num_misses/num_cache_acc );
      $display( "num_mem_accesses        = %0d", num_mem_acc       );
      $display( "num_refills             = %0d", num_refills       );
      $display( "num_evicts              = %0d", num_evicts        );
      $display( "amal                    = %f",
                                  1.0*th.vc_trace.cycles/num_cache_acc );

      //$display( "avg_num_cycles_per_inst = %f",
      //                            th.vc_trace.cycles/(1.0*num_insts) );
    end

    // Finish simulation

    $finish;

  end

endmodule
