//=========================================================================
// Processor Test Harness
//=========================================================================
// This harness is meant to be instantiated for the ISA simulator like this:
//
//  `define LAB2_PROC_IMPL_STR "lab2-proc-ISASimulator-%INST%"
//  `define LAB2_PROC_TEST_CASES_FILE lab2-proc-test-cases-%INST%.v
//
//  `include "lab2-proc-ISASimulator.v"
//  `include "lab2-proc-isa-test-harness.v"
//
// This test harness provides the logic and includes the test cases
// specified in `LAB2_PROC_TEST_CASES_FILE.

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestRandDelayMem_2ports.v"
`include "vc-test.v"
`include "vc-preprocessor.v"
`include "pisa-inst.v"
`include "vc-trace.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_mem_nbytes  = 1 << 16, // size of physical memory in bytes
  parameter p_num_msgs    = 1024
)(
  input  logic        clk,
  input  logic        reset,
  input  logic        mem_clear,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] mem_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  // Local parameters

  localparam c_req_msg_nbits  = `VC_MEM_REQ_MSG_NBITS(8,32,32);
  localparam c_resp_msg_nbits = `VC_MEM_RESP_MSG_NBITS(8,32);
  localparam c_opaque_nbits   = 8;
  localparam c_data_nbits     = 32;   // size of mem message data in bits
  localparam c_addr_nbits     = 32;   // size of mem message address in bits

  // wires

  logic [`LAB2_PROC_FROM_MNGR_MSG_NBITS-1:0]   src_msg;
  logic                                        src_val;
  logic                                        src_rdy;
  logic                                        src_done;

  logic [`LAB2_PROC_TO_MNGR_MSG_NBITS-1:0]     sink_msg;
  logic                                        sink_val;
  logic                                        sink_rdy;
  logic                                        sink_done;

  // from mngr source

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (`LAB2_PROC_FROM_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  src
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (src_max_delay),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (src_done)
  );

  // ISA simulator

  lab2_proc_ISASimulator
  #(p_mem_nbytes, c_opaque_nbits, c_addr_nbits, c_data_nbits) isa_sim
  (
    .clk           (clk),
    .reset         (reset),
    .mem_clear     (mem_clear),
    .max_delay     (mem_max_delay),

    .from_mngr_msg (src_msg),
    .from_mngr_val (src_val),
    .from_mngr_rdy (src_rdy),

    .to_mngr_msg   (sink_msg),
    .to_mngr_val   (sink_val),
    .to_mngr_rdy   (sink_rdy)
  );

  // to mngr sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (`LAB2_PROC_TO_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  sink
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (sink_max_delay),

    .val       (sink_val),
    .rdy       (sink_rdy),
    .msg       (sink_msg),

    .done      (sink_done)
  );

  assign done = src_done && sink_done;

  `VC_TRACE_BEGIN
  begin
    src.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    isa_sim.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    sink.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `LAB2_PROC_IMPL_STR )

  pisa_InstTasks pisa();

  // the reset vector (the PC that the processor will start fetching from
  // after a reset)
  localparam c_reset_vector = 32'h1000;

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  logic         th_reset = 1;
  logic         th_mem_clear;
  logic  [31:0] th_src_max_delay;
  logic  [31:0] th_mem_max_delay;
  logic  [31:0] th_sink_max_delay;
  logic  [31:0] th_inst_asm_str;
  logic  [31:0] th_addr;
  logic  [31:0] th_src_idx;
  logic  [31:0] th_sink_idx;
  logic         th_done;

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

  //----------------------------------------------------------------------
  // load_mem: helper task to load one word into memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input logic [31:0] addr,
    input logic [31:0] data
  );
  begin
    th.isa_sim.M[ addr >> 2 ] = data;
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source
  //----------------------------------------------------------------------

  task load_from_mngr
  (
    input logic [ 9:0]                                i,
    input logic [`LAB2_PROC_FROM_MNGR_MSG_NBITS-1:0]  msg
  );
  begin
    th.src.src.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_to_mngr: helper task to load an entry into the to_mngr sink
  //----------------------------------------------------------------------

  task load_to_mngr
  (
    input logic [ 9:0]                                i,
    input logic [`LAB2_PROC_TO_MNGR_MSG_NBITS-1:0]    msg
  );
  begin
    th.sink.sink.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // clear_mem: clear the contents of memory and test sources and sinks
  //----------------------------------------------------------------------

  task clear_mem;
  begin
    #1;   th_mem_clear = 1'b1;
    #20;  th_mem_clear = 1'b0;
    th_src_idx = 0;
    th_sink_idx = 0;
    // in case there are no srcs/sinks, we set the first elements of them
    // to xs
    load_from_mngr( 0, 32'hxxxxxxxx );
    load_to_mngr(   0, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_src: add a data to the test src
  //----------------------------------------------------------------------

  task init_src
  (
    input logic [31:0] data
  );
  begin
    load_from_mngr( th_src_idx, data );
    th_src_idx = th_src_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_from_mngr( th_src_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_sink: add a data to the test sink
  //----------------------------------------------------------------------

  task init_sink
  (
    input logic [31:0] data
  );
  begin
    load_to_mngr( th_sink_idx, data );
    th_sink_idx = th_sink_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_to_mngr( th_sink_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // inst: assemble and put instruction to next addr
  //----------------------------------------------------------------------

  task inst
  (
    input logic [25*8-1:0] asm_str
  );
  begin
    th_inst_asm_str = pisa.asm( th_addr, asm_str );
    load_mem( th_addr, th_inst_asm_str );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // data: put data_in to next addr, useful for mem ops
  //----------------------------------------------------------------------

  task data
  (
    input logic [31:0] data_in
  );
  begin
    load_mem( th_addr, data_in );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // address: each consecutive call to inst and data would be put after
  // this address
  //----------------------------------------------------------------------

  task address
  (
    input logic [31:0] addr
  );
  begin
    th_addr = addr;
  end
  endtask

  //----------------------------------------------------------------------
  // test_insert_nops: insert count many nops
  //----------------------------------------------------------------------

  integer i;

  task test_insert_nops
  (
    input logic [31:0] count
  );
  begin
    for ( i = 0; i < count; i = i + 1 )
      inst( "nop" );
  end
  endtask

  //----------------------------------------------------------------------
  // Helper task to initialize random delay setup
  //----------------------------------------------------------------------

  task init_rand_delays
  (
    input logic [31:0] src_max_delay,
    input logic [31:0] mem_max_delay,
    input logic [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  //----------------------------------------------------------------------
  // Helper task to run test
  //----------------------------------------------------------------------

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
  // include the actual test cases
  //----------------------------------------------------------------------

  `include `LAB2_PROC_TEST_CASES_FILE

  `VC_TEST_SUITE_END
endmodule

