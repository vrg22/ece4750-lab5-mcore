//=========================================================================
// Processor Simulator Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define LAB5_MCORE_IMPL     lab5_mcore_Impl
//  `define LAB5_MCORE_IMPL_STR "lab5-mcore-Impl"
//
//  `include "lab5-mcore-Impl.v"
//  `include "lab5-mcore-sim-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestRandDelayMem_2ports.v"
`include "vc-test.v"
`include "vc-trace.v"

`include "pisa-inst.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_mem_nbytes  = 1 << 20, // size of physical memory in bytes
  parameter p_num_msgs    = 1024
)(
  input  logic        clk,
  input  logic        reset,
  input  logic        mem_clear,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] mem_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        stats_en,
  output logic        done
);

  // Local parameters

  localparam c_req_msg_nbits  = `VC_MEM_REQ_MSG_NBITS(8,32,128);
  localparam c_resp_msg_nbits = `VC_MEM_RESP_MSG_NBITS(8,128);
  localparam c_opaque_nbits   = 8;
  localparam c_data_nbits     = 128;  // size of mem message data in bits
  localparam c_addr_nbits     = 32;   // size of mem message address in bits

  // wires

  logic [31:0] src_msg;
  logic        src_val;
  logic        src_rdy;
  logic        src_done;

  logic [31:0] sink_msg;
  logic        sink_val;
  logic        sink_rdy;
  logic        sink_done;

  // from mngr source

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (32),
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

  // memory

  logic                        memreq0_val;
  logic                        memreq0_rdy;
  logic [c_req_msg_nbits-1:0]  memreq0_msg;

  logic                        memresp0_val;
  logic                        memresp0_rdy;
  logic [c_resp_msg_nbits-1:0] memresp0_msg;

  logic                        memreq1_val;
  logic                        memreq1_rdy;
  logic [c_req_msg_nbits-1:0]  memreq1_msg;

  logic                        memresp1_val;
  logic                        memresp1_rdy;
  logic [c_resp_msg_nbits-1:0] memresp1_msg;

  vc_TestRandDelayMem_2ports
  #(p_mem_nbytes, c_opaque_nbits, c_addr_nbits, c_data_nbits) mem
  (
    .clk          (clk),
    .reset        (reset),
    .mem_clear    (mem_clear),

    .max_delay    (mem_max_delay),

    .memreq0_val  (memreq0_val),
    .memreq0_rdy  (memreq0_rdy),
    .memreq0_msg  (memreq0_msg),

    .memresp0_val (memresp0_val),
    .memresp0_rdy (memresp0_rdy),
    .memresp0_msg (memresp0_msg),

    .memreq1_val  (memreq1_val),
    .memreq1_rdy  (memreq1_rdy),
    .memreq1_msg  (memreq1_msg),

    .memresp1_val (memresp1_val),
    .memresp1_rdy (memresp1_rdy),
    .memresp1_msg (memresp1_msg)
  );

  // processor-cache-network

  `LAB5_MCORE_IMPL proc_cache_net
  (
    .clk           (clk),
    .reset         (reset),

    .memreq0_val   (memreq0_val),
    .memreq0_rdy   (memreq0_rdy),
    .memreq0_msg   (memreq0_msg),

    .memresp0_val  (memresp0_val),
    .memresp0_rdy  (memresp0_rdy),
    .memresp0_msg  (memresp0_msg),

    .memreq1_val   (memreq1_val),
    .memreq1_rdy   (memreq1_rdy),
    .memreq1_msg   (memreq1_msg),

    .memresp1_val  (memresp1_val),
    .memresp1_rdy  (memresp1_rdy),
    .memresp1_msg  (memresp1_msg),

    .proc0_from_mngr_msg (src_msg),
    .proc0_from_mngr_val (src_val),
    .proc0_from_mngr_rdy (src_rdy),

    .proc0_to_mngr_msg   (sink_msg),
    .proc0_to_mngr_val   (sink_val),
    .proc0_to_mngr_rdy   (sink_rdy),

    .stats_en            (stats_en)

  );

  // to mngr sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (32),
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
    proc_cache_net.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    sink.trace( trace_str );
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

  logic [(512<<3)-1:0] exe_filename;
  logic [(512<<3)-1:0] vcd_dump_file_name;
  integer              stats_en = 0;
  integer              verify_en = 0;
  integer              max_cycles;
  integer              show_all_failed = 0;

  initial begin

    // Input dataset

    if ( !$value$plusargs( "exe=%s", exe_filename ) ) begin
      // default dataset is none
      exe_filename = "";
    end

    // Maximum cycles

    if ( !$value$plusargs( "max-cycles=%d", max_cycles ) ) begin
      max_cycles = 100000;
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

    // Show all failed

    if ( $test$plusargs( "show-all-failed" ) ) begin
      show_all_failed = 1;
    end

    // Usage message

    if ( $test$plusargs( "help" ) ) begin
      $display( "" );
      $display( " lab5-mcore-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +exe=<executable>     : path of vmh file" );
      $display( "   +max-cycles=<int>     : max cycles to wait until done" );
      $display( "   +trace=<int>          : 1 turns on line tracing" );
      $display( "   +dump-vcd=<file-name> : dump VCD to given file name" );
      $display( "   +stats                : display statistics" );
      $display( "   +show-all-failed      : do not exit on first fail" );
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

  pisa_InstTasks pisa();

  // the reset vector (the PC that the processor will start fetching from
  // after a reset)
  localparam c_reset_vector = 32'h1000;

  logic        th_reset = 1'b1;
  logic        th_mem_clear;
  logic [31:0] th_src_max_delay;
  logic [31:0] th_mem_max_delay;
  logic [31:0] th_sink_max_delay;
  logic [31:0] th_inst_asm_str;
  logic [31:0] th_addr;
  logic [31:0] th_src_idx;
  logic [31:0] th_sink_idx;
  logic        th_stats_en;
  logic        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .stats_en       (th_stats_en),
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
    th.mem.mem.m[ addr >> 2 ] = data;
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source
  //----------------------------------------------------------------------

  task load_from_mngr
  (
    input logic [ 9:0] i,
    input logic [31:0] msg
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
    input logic [ 9:0] i,
    input logic [31:0] msg
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
  // init_rand_delays: helper task to initialize random delay setup
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
  // Drive the simulation
  //----------------------------------------------------------------------

  // number of instructions and cycles for stats

  integer num_insts  = 0;
  integer num_cycles = 0;

  integer fh;
  integer e;

  logic [60*8-1:0] ubmark_name;

  integer fail_idx = 0;
  integer fail_arr[7:0];
  logic done = 1'b0;

  integer i;

  initial begin

    #1;

    // we don't have delays for simulation
    init_rand_delays( 0, 0, 0 );
    clear_mem;

    for ( i = 0; i < 10000; i = i + 1 )
      init_sink( 0 );

    if ( exe_filename == "" ) begin
      $display( "" );
      $display( " ERROR: need to provide a vmh file using +exe flag" );
      $display( "" );
      $finish_and_return(1);
    end

    // extract the ubmark name from the executable

    e = $sscanf( exe_filename, " %s", ubmark_name);

    fh = $fopen( exe_filename, "r" );

    if ( !fh ) begin
      $display( "" );
      $display( " ERROR: Could not open vmh file (%s)", exe_filename );
      $display( "" );
      $finish_and_return(1);
    end
    $fclose( fh );

    $readmemh( exe_filename, th.mem.mem.m );

    // Reset signal

         th_reset = 1'b1;
    #20; th_reset = 1'b0;

    // Run the simulation

    while ( !done && (th.vc_trace.cycles < max_cycles) ) begin
      th.display_trace();

      // we count the stats when stats_en is high
      if ( th_stats_en ) begin

        num_cycles = num_cycles + 1;

        // we have a unique instruction when the pipe control in M has
        // next_val asserted
        if ( th.proc_cache_net.`LAB5_MCORE_PROC0.ctrl.val_MW )
          num_insts = num_insts + 1;

      end

      // we have a failure when the processor sends non-zero value
      if ( th.sink_val && th.sink_rdy ) begin
        if ( fail_idx == 0 && th.sink_msg === 32'h0 ) begin
          $display( "" );
          $display( "  [ passed ] " );
          $display( "" );
          done = 1;
        end else begin
          // when there is a failure, the processor communicates the
          // failure message
          fail_arr[ fail_idx ] = th.sink_msg;
          fail_idx = fail_idx + 1;

          if ( fail_idx == 4 ) begin
            $display( "" );
            $display( "  [ FAILED ] dest[%d] != ref[%d] (%d != %d)",
                 fail_arr[1], fail_arr[1], fail_arr[2], fail_arr[3] );
            $display( "" );
            if ( show_all_failed )
              fail_idx = 0;
            else
              $finish_and_return( 1 );
          end
        end
      end
      #10;
    end

    // Check that the simulation actually finished

    if ( !done ) begin
      $display( "" );
      $display( " ERROR: Simulation did not finish in time. Maybe increase" );
      $display( " the simulation time limit using the +max-cycles=<int>" );
      $display( " command line parameter?" );
      $display( "" );
      $finish_and_return(1);
    end

    // Output stats

    if ( stats_en ) begin
      $display( "num_cycles              = %0d", num_cycles );
      $display( "num_insts               = %0d", num_insts );
      $display( "avg_num_cycles_per_inst = %f",
                                  num_cycles/(1.0*num_insts) );
    end

    // Finish simulation

    $finish;

  end

endmodule


