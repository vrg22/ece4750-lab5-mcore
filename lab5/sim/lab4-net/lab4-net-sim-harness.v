//========================================================================
// Simulator Harness for Ring Network
//========================================================================

`include "vc-net-msgs.v"
`include "vc-param-utils.v"
`include "vc-queues.v"
`include "vc-trace.v"

`define WARMUP 2'h0
`define TAG    2'h1
`define WAIT   2'h2

`define URANDOM    0
`define TORNADO    1
`define NEIGHBOR   3
`define PARTITION2 5
`define PARTITION4 6
`define COMPLEMENT 7
`define REVERSE    8
`define ROTATION   9

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_payload_nbits = 8,
  parameter p_opaque_nbits  = 8,
  parameter p_srcdest_nbits = 2
)
(
  input  logic            clk,
  input  logic            reset,
  input  logic [31:0]     injection_rate,
  // state is WARMUP, TAG or WAIT
  input  logic [1:0]      state,
  input  logic [31:0]     pattern,
  output logic            saturated
);

  // Local parameters

  parameter  c_num_ports     = 8;

  // shorter names

  localparam p = p_payload_nbits;
  localparam o = p_opaque_nbits;
  localparam s = p_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  localparam c_in_queue_num_msgs = 128;

  // Network wires

  logic [c_num_ports-1:0]                 net_in_val;
  logic [c_num_ports-1:0]                 net_in_rdy;
  logic [c_num_ports*c_net_msg_nbits-1:0] net_in_msg;

  logic [c_num_ports-1:0]                 net_out_val;
  logic [c_num_ports-1:0]                 net_out_rdy;
  logic [c_num_ports*c_net_msg_nbits-1:0] net_out_msg;

  // Saturation related wires

  logic [c_num_ports-1:0]  src_saturated;
  assign saturated =  ( | src_saturated );

  //----------------------------------------------------------------------
  // Generate loop for source/sink
  //----------------------------------------------------------------------

  genvar i;

  generate
  for ( i = 0; i < c_num_ports; i = i + 1 ) begin: SRC_SINK_INIT

    // local wires for the source and sink iteration

    logic                                        src_val;
    logic                                        src_rdy;
    logic [c_net_msg_nbits-1:0]                  src_msg;

    logic [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]     src_msg_src;
    logic [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]    src_msg_dest;
    logic [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]  src_msg_opaque;
    logic [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0] src_msg_payload;

    logic                                        sink_val;
    logic                                        sink_rdy;
    logic [c_net_msg_nbits-1:0]                  sink_msg;

    logic [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]     sink_msg_src;
    logic [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]    sink_msg_dest;
    logic [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]  sink_msg_opaque;
    logic [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0] sink_msg_payload;

    // network message pack and unpack modules

    vc_NetMsgPack #(p,o,s) src_msg_pack
    (
      .dest     (src_msg_dest),
      .src      (src_msg_src),
      .opaque   (src_msg_opaque),
      .payload  (src_msg_payload),

      .msg      (src_msg)
    );

    vc_NetMsgUnpack #(p,o,s) sink_msg_unpack
    (
      .msg      (sink_msg),

      .dest     (sink_msg_dest),
      .src      (sink_msg_src),
      .opaque   (sink_msg_opaque),
      .payload  (sink_msg_payload)
    );

    // input queue

    vc_Queue
    #(
      .p_type       (`VC_QUEUE_BYPASS),
      .p_msg_nbits  (c_net_msg_nbits),
      .p_num_msgs   (c_in_queue_num_msgs)
    )
    in_queue
    (
      .clk      (clk),
      .reset    (reset),

      .enq_val  (src_val),
      .enq_rdy  (src_rdy),
      .enq_msg  (src_msg),

      .deq_val  (net_in_val[`VC_PORT_PICK_FIELD(1,i)]),
      .deq_rdy  (net_in_rdy[`VC_PORT_PICK_FIELD(1,i)]),
      .deq_msg  (net_in_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)])
    );

    assign sink_val = net_out_val[`VC_PORT_PICK_FIELD(1,i)];
    assign sink_msg = net_out_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)];
    assign net_out_rdy[`VC_PORT_PICK_FIELD(1,i)] = sink_rdy;

    // we are always ready to receive

    assign sink_rdy = 1'b1;

    // src is saturated when it doesn't accept the input packet

    assign src_saturated[`VC_PORT_PICK_FIELD(1,i)] = ( src_val && !src_rdy);

    // total amount of latency, number of tagged messages sent and number
    // of tagged messages received

    logic [31:0] stat_lat           = 0;
    logic [31:0] stat_num_msgs      = 0;
    logic [31:0] stat_recv_num_msgs = 0;

    // the logic to send and receive packets based on the injection rate
    // and traffic

    integer latency;
    always @(posedge clk) begin

      // we delay some amount to make sure any packet we are waiting for
      // have arrived

      #1;

      // we randomly decide to send or not given the injection rate

      if ( ( $random % 100 ) < injection_rate ) begin

        src_val     <= 1'b1;
        src_msg_src <= i;

        // we pick the destination depending on the pattern input

        case ( pattern )
          `URANDOM:    src_msg_dest   <= $random % c_num_ports;
          `PARTITION2: src_msg_dest   <= ($random & 3'b011) | (i & 3'b100);
          `PARTITION4: src_msg_dest   <= ($random & 3'b001) | (i & 3'b110);
          `TORNADO:    src_msg_dest   <= (i + 3) % c_num_ports;
          `NEIGHBOR:   src_msg_dest   <= (i + 1) % c_num_ports;
          `COMPLEMENT: src_msg_dest   <= ~i;
          `REVERSE:    src_msg_dest   <= {i[0], i[1], i[2]};
          `ROTATION:   src_msg_dest   <= {i[0], i[2], i[1]};
        endcase

        // we put random data in the opaque field

        src_msg_opaque <= $random % ( (1 << p_opaque_nbits) - 1 );

        // if the state is tag, we tag the injected packets with the
        // current time

        if ( state == `TAG ) begin
          // we encode the current time in the payload so that we can
          // calculate the latency

          src_msg_payload <= vc_trace.cycles;
          stat_num_msgs <= stat_num_msgs + 1;

        end else begin
          // otherwise the payload is just 0
          src_msg_payload <= 'h0;
        end

      end else begin
        src_val <= 1'b0;
      end

      // we check the received message

      if ( sink_val && sink_rdy ) begin

        // if we are waiting for tagged messages and this is a tagged
        // message

        if ( sink_msg_payload != 0 ) begin
          // add the latency information to the stats
          stat_lat <= stat_lat + (vc_trace.cycles - sink_msg_payload);
          stat_recv_num_msgs <= stat_recv_num_msgs + 1;
        end
      end

    end

    // line tracing for the source and sink

    logic [`VC_TRACE_NBITS_TO_NCHARS(c_net_msg_nbits)*8-1:0] src_str;
    logic [`VC_TRACE_NBITS_TO_NCHARS(c_net_msg_nbits)*8-1:0] sink_str;

    task trace_src( inout [`VC_TRACE_NBITS-1:0] trace_str );
    begin
      $sformat( src_str, "%x>%x",
                src_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
                src_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
      vc_trace.append_val_rdy_str( trace_str, src_val, src_rdy, src_str );
    end
    endtask

    task trace_sink( inout [`VC_TRACE_NBITS-1:0] trace_str );
    begin
      $sformat( sink_str, "%x>%x",
                sink_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
                sink_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)] );
      vc_trace.append_val_rdy_str( trace_str, sink_val, sink_rdy, sink_str );
    end
    endtask

    // adds the local stats to the global stats

    task add_to_stats
    (
      inout [31:0] lat,
      inout [31:0] num_msgs,
      inout [31:0] recv_num_msgs
    );
    begin
      lat           = lat + stat_lat;
      num_msgs      = num_msgs + stat_num_msgs;
      recv_num_msgs = recv_num_msgs + stat_recv_num_msgs;

      // clear the local counters
      stat_lat = 0;
      stat_num_msgs = 0;
      stat_recv_num_msgs = 0;
    end
    endtask

  end
  endgenerate

  //----------------------------------------------------------------------
  // Ring Network
  //----------------------------------------------------------------------

  `LAB4_NET_IMPL
  #(
    .p_payload_nbits  (p_payload_nbits  ),
    .p_opaque_nbits   (p_opaque_nbits   ),
    .p_srcdest_nbits  (p_srcdest_nbits  )
  )
  net
  (
    .clk      (clk),
    .reset    (reset),

    .in_val   (net_in_val),
    .in_rdy   (net_in_rdy),
    .in_msg   (net_in_msg),

    .out_val  (net_out_val),
    .out_rdy  (net_out_rdy),
    .out_msg  (net_out_msg)
  );

  //----------------------------------------------------------------------
  // Stats
  //----------------------------------------------------------------------

  // refresh the stats from each src/sink

  logic [31:0] lat      = 0;
  logic [31:0] num_msgs = 0;
  logic [31:0] recv_num_msgs = 0;
  task refresh_stats;
  begin
    // collect stats from each src/sink
    SRC_SINK_INIT[0].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[1].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[2].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[3].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[4].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[5].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[6].add_to_stats( lat, num_msgs, recv_num_msgs );
    SRC_SINK_INIT[7].add_to_stats( lat, num_msgs, recv_num_msgs );

  end
  endtask

  // reset stats

  task clear_stats;
  begin
    lat           = 0;
    num_msgs      = 0;
    recv_num_msgs = 0;
  end
  endtask

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  integer j;
  `VC_TRACE_BEGIN
  begin

    for ( j = 0; j < c_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_8( SRC_SINK_INIT, j, trace_src( trace_str ) );
    end

    vc_trace.append_str( trace_str, " > " );

    net.trace( trace_str );

    vc_trace.append_str( trace_str, " > " );

    for ( j = 0; j < c_num_ports; j = j + 1 ) begin
      if ( j != 0 )
        vc_trace.append_str( trace_str, "|" );

      `VC_GEN_CALL_8( SRC_SINK_INIT, j, trace_sink( trace_str ) );
    end

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

  initial begin

    // Input dataset

    if ( !$value$plusargs( "input=%s", input_dataset ) ) begin
      // default dataset is none
      input_dataset = "";
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

    // Usage message

    if ( $test$plusargs( "help" ) ) begin
      $display( "" );
      $display( " lab4-net-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +input=<dataset>      : {urandom,partition2,partition4," );
      $display( "                           tornado,neighbor,complement," );
      $display( "                           reverse,rotation}" );
      $display( "   +trace=<int>          : 1 turns on line tracing" );
      $display( "   +dump-vcd=<file-name> : dump VCD to given file name" );
      $display( "   +stats                : display statistics" );
      $display( "" );
      $finish;
    end

  end

  //----------------------------------------------------------------------
  // Generate clock
  //----------------------------------------------------------------------

  logic clk = 1;
  always #5 clk = ~clk;

  //----------------------------------------------------------------------
  // Instantiate the harness
  //----------------------------------------------------------------------

  // Local parameters

  localparam c_num_ports     = 8;

  localparam c_payload_nbits = 16;
  localparam c_opaque_nbits  = 8;
  localparam c_srcdest_nbits = 3;

  // shorter names

  localparam p = c_payload_nbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  logic        th_reset = 1;
  logic [31:0] th_injection_rate;
  logic [31:0] th_pattern;
  logic        th_saturated;
  logic [1:0]  th_state;

  TestHarness
  #(
    .p_payload_nbits    (c_payload_nbits),
    .p_opaque_nbits     (c_opaque_nbits),
    .p_srcdest_nbits    (c_srcdest_nbits)
  )
  th
  (
    .clk            (clk),
    .reset          (th_reset),
    .injection_rate (th_injection_rate),
    .saturated      (th_saturated),
    .pattern        (th_pattern),
    .state          (th_state)
  );


  //----------------------------------------------------------------------
  // Drive the simulation
  //----------------------------------------------------------------------

  // parameters for the evaluation

  integer warmup_cycles = 500;
  integer tag_window    = 200;
  integer inj_step      = 8;
  integer inj_shamt_mult= 2;
  integer inj_shamt;
  integer num_cycles    = 0;
  // we're checking prev value to change the injection step appropriately
  real    running_avg_lat = 0.0;
  real    avg_lat;
  real    zero_load_lat;

  initial begin

    #1;

    if          ( input_dataset == "urandom"    ) begin
      th_pattern = `URANDOM;
    end else if ( input_dataset == "partition2" ) begin
      th_pattern = `PARTITION2;
    end else if ( input_dataset == "partition4" ) begin
      th_pattern = `PARTITION4;
    end else if ( input_dataset == "tornado"    ) begin
      th_pattern = `TORNADO;
    end else if ( input_dataset == "neighbor"   ) begin
      th_pattern = `NEIGHBOR;
    end else if ( input_dataset == "complement" ) begin
      th_pattern = `COMPLEMENT;
    end else if ( input_dataset == "reverse"    ) begin
      th_pattern = `REVERSE;
    end else if ( input_dataset == "rotation"   ) begin
      th_pattern = `ROTATION;
    end

    else begin
      $display( "" );
      $display( " ERROR: Unrecognized input dataset specified with +input! (%s)",
                            input_dataset );
      $display( "" );
      $finish_and_return(1);
    end

    // Set the injection rate

    th_injection_rate = 5;

    // Reset signal

         th_reset = 1'b1;
    #20; th_reset = 1'b0;


    // Run the simulation

    begin: INJ_SWEEP

      for ( th_injection_rate = 5; th_injection_rate < 100;
                           th_injection_rate = th_injection_rate + inj_step )
      begin

        // Clear stats

        th_state = `WARMUP;
        th.clear_stats;


        // reset num cycles

        num_cycles = 0;

        while ( !( th_state == `WAIT &&
                       (th.num_msgs == th.recv_num_msgs) ) ) begin
          th.display_trace();

          th.refresh_stats;

          if ( num_cycles == warmup_cycles ) begin
            th.clear_stats;
            th_state = `TAG;
          end

          if ( num_cycles == warmup_cycles + tag_window ) begin
            th_state = `WAIT;
          end


          // if we are saturated, we break out
          if ( th_saturated )
            disable INJ_SWEEP;

          num_cycles = num_cycles + 1;
          #10;
        end

        avg_lat = 1.0 * th.lat / th.num_msgs;

        // dynamically reduce inj_step depending on the slope

        if ( ( running_avg_lat != 0.0 ) &&
                          ( avg_lat > running_avg_lat ) ) begin
          inj_shamt = ( (avg_lat / running_avg_lat) - 1 ) * inj_shamt_mult;
          inj_step  = inj_step >> inj_shamt;
        end

        if ( inj_step == 0 )
          inj_step = 1;

        // store the zero load latency

        if ( th_injection_rate == 5 )
          zero_load_lat = avg_lat;

        // display the data points for plotting

        $display( "%0d %f", th_injection_rate, avg_lat );

        if ( running_avg_lat == 0.0 )
          running_avg_lat = avg_lat;
        else
          running_avg_lat = 0.5 * avg_lat + 0.5 * running_avg_lat;

      end
    end

    // to make better looking plot, we assume the latency is 100 when the
    // network is saturated

    if ( th_injection_rate < 100 )
      $display( "%0d %f", th_injection_rate, 100 );



    // Output stats

    if ( stats_en ) begin
      $display( "* zero_load_lat         = %f",  zero_load_lat   );
      $display( "* sat_inj_rate          = %0d", th_injection_rate   );

    end

    // Finish simulation

    $finish;

  end

endmodule

