//========================================================================
// Test Harness for Ring Network
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-test.v"
`include "vc-net-msgs.v"
`include "vc-param-utils.v"
`include "vc-trace.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_payload_nbits = 8,
  parameter p_opaque_nbits  = 8,
  parameter p_srcdest_nbits = 2
)
(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  // Local parameters

  parameter  c_num_ports     = 8;

  // shorter names

  localparam p = p_payload_nbits;
  localparam o = p_opaque_nbits;
  localparam s = p_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  // Test network wires

  logic [c_num_ports-1:0]                 net_in_val;
  logic [c_num_ports-1:0]                 net_in_rdy;
  logic [c_num_ports*c_net_msg_nbits-1:0] net_in_msg;

  logic [c_num_ports-1:0]                 net_out_val;
  logic [c_num_ports-1:0]                 net_out_rdy;
  logic [c_num_ports*c_net_msg_nbits-1:0] net_out_msg;

  //----------------------------------------------------------------------
  // Generate loop for source/sink
  //----------------------------------------------------------------------

  genvar i;

  generate
  for ( i = 0; i < c_num_ports; i = i + 1 ) begin: SRC_SINK_INIT

    // local wires for the source and sink iteration

    logic                        src_val;
    logic                        src_rdy;
    logic [c_net_msg_nbits-1:0]  src_msg;
    logic                        src_done;

    logic                        sink_val;
    logic                        sink_rdy;
    logic [c_net_msg_nbits-1:0]  sink_msg;

    logic                        sink_done;

    // connect the local wires to the wide network ports

    assign net_in_val[`VC_PORT_PICK_FIELD(1,i)] = src_val;
    assign net_in_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)] = src_msg;
    assign src_rdy = net_in_rdy[`VC_PORT_PICK_FIELD(1,i)];

    assign sink_val = net_out_val[`VC_PORT_PICK_FIELD(1,i)];
    assign sink_msg = net_out_msg[`VC_PORT_PICK_FIELD(c_net_msg_nbits,i)];
    assign net_out_rdy[`VC_PORT_PICK_FIELD(1,i)] = sink_rdy;

    vc_TestRandDelaySource#(c_net_msg_nbits) src
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (src_max_delay),
      .val        (src_val),
      .rdy        (src_rdy),
      .msg        (src_msg),
      .done       (src_done)
    );

    // We use an unordered sink because the messages can come out of order

    vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink
    (
      .clk        (clk),
      .reset      (reset),
      .max_delay  (sink_max_delay),
      .val        (sink_val),
      .rdy        (sink_rdy),
      .msg        (sink_msg),
      .done       (sink_done)
    );

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


  end
  endgenerate

  //----------------------------------------------------------------------
  // Ring Network under test
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

  // Accumulate done signals from all sources and sinks

  integer j;
  always @(*) begin
    done       = 1;
    for ( j = 0; j < c_num_ports; j = j + 1 ) begin
      `VC_GEN_CALL_8( done = done & SRC_SINK_INIT, j, src_done );
      `VC_GEN_CALL_8( done = done & SRC_SINK_INIT, j, sink_done );
    end
  end

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

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
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `LAB4_NET_IMPL_STR )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Local parameters

  localparam c_num_ports     = 8;

  localparam c_payload_nbits = 8;
  localparam c_opaque_nbits  = 8;
  localparam c_srcdest_nbits = 3;

  // shorter names

  localparam p = c_payload_nbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  logic        th_reset = 1'b1;
  logic [31:0] th_src_max_delay;
  logic [31:0] th_sink_max_delay;
  logic        th_done;

  logic [10:0] th_src_index  [10:0];
  logic [10:0] th_sink_index [10:0];

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
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  // Helper task to initialize source/sink delays
  integer i;
  task init_rand_delays
  (
    input logic [31:0] src_max_delay,
    input logic [31:0] sink_max_delay
  );
  begin
    // we also clear the src/sink indexes and contents
    for ( i = 0; i < c_num_ports; i = i + 1 ) begin
      th_src_index[i] = 0;
      th_sink_index[i] = 0;
      `VC_GEN_CALL_8( th.SRC_SINK_INIT, i,
                      src.src.m[0] = 'hx );
      `VC_GEN_CALL_8( th.SRC_SINK_INIT, i,
                      sink.sink.m[0] = 'hx );
    end
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask


  task init_src
  (
    input logic [31:0]                port,

    input logic [c_net_msg_nbits-1:0] msg
  );
  begin

    `VC_GEN_CALL_8( th.SRC_SINK_INIT, port,
                    src.src.m[th_src_index[port]] = msg );

    `VC_GEN_CALL_8( th.SRC_SINK_INIT, port,
                    src.src.m[th_src_index[port] + 1] = 'hx );

    // increment the index
    th_src_index[port] = th_src_index[port] + 1;

  end
  endtask

  task init_sink
  (
    input logic [31:0]   port,

    input logic [c_net_msg_nbits-1:0] msg
  );
  begin

    `VC_GEN_CALL_8( th.SRC_SINK_INIT, port,
                    sink.sink.m[th_sink_index[port]] = msg );

    `VC_GEN_CALL_8( th.SRC_SINK_INIT, port,
                    sink.sink.m[th_sink_index[port] + 1] = 'hx );

    // increment the index
    th_sink_index[port] = th_sink_index[port] + 1;

  end
  endtask

  logic [c_net_msg_nbits-1:0] th_port_msg;

  task init_net_msg
  (
    input logic [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]     src,
    input logic [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]    dest,
    input logic [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]  opaque,
    input logic [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0] payload
  );
  begin

    th_port_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)]    = dest;
    th_port_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)]     = src;
    th_port_msg[`VC_NET_MSG_PAYLOAD_FIELD(p,o,s)] = payload;
    th_port_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)]  = opaque;

    // call the respective src and sink
    init_src(  src,  th_port_msg );
    init_sink( dest, th_port_msg );

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.vc_trace.cycles < 1500) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // basic test 1: single source
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test 1: single source" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h0, 8'h00, 8'hce );
    init_net_msg( 3'h0, 3'h1, 8'h01, 8'hff );
    init_net_msg( 3'h0, 3'h2, 8'h02, 8'h80 );
    init_net_msg( 3'h0, 3'h3, 8'h03, 8'hc0 );
    init_net_msg( 3'h0, 3'h4, 8'h04, 8'h55 );
    init_net_msg( 3'h0, 3'h5, 8'h05, 8'h96 );
    init_net_msg( 3'h0, 3'h6, 8'h06, 8'h32 );
    init_net_msg( 3'h0, 3'h7, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  // add more test cases

  //----------------------------------------------------------------------
  // basic test 2: send to self
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test 2: send to self" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h0, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h1, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h2, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h3, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h4, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h5, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h6, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h7, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // basic test 3: A to B and B to A neighboring
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test 3: A to B and B to A neighboring" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h1, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h0, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h3, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h2, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h5, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h4, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h7, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h6, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // basic test 4: A to B tornado forwards
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "basic test 4: A to B tornado forwards" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h3, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h4, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h5, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // basic test 5: A to B tornado backwards
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "basic test 5: A to B tornado backwards" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h5, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h6, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h7, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h0, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h1, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h2, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h3, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h4, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // basic test 6: single destination, last router
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "basic test 6: single destination, last router" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h7, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h7, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h7, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h7, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h7, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h7, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h7, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END


  //----------------------------------------------------------------------
  // basic test 7: single destination, first router
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "basic test 6: single destination, first router" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h0, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h0, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h0, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h0, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h0, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h0, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h0, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END  


  //----------------------------------------------------------------------
  // basic test 8: A to B neighboring forwards
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "basic test 8: A to B neighboring, forwards" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h1, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h2, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h3, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h4, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h5, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h6, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h7, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h0, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END  


  //----------------------------------------------------------------------
  // basic test 9: A to B neighboring backwards
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "basic test 8: A to B neighboring, backwards" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h7, 8'h00, 8'hce );
    init_net_msg( 3'h1, 3'h0, 8'h01, 8'hff );
    init_net_msg( 3'h2, 3'h1, 8'h02, 8'h80 );
    init_net_msg( 3'h3, 3'h2, 8'h03, 8'hc0 );
    init_net_msg( 3'h4, 3'h3, 8'h04, 8'h55 );
    init_net_msg( 3'h5, 3'h4, 8'h05, 8'h96 );
    init_net_msg( 3'h6, 3'h5, 8'h06, 8'h32 );
    init_net_msg( 3'h7, 3'h6, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END   


  //----------------------------------------------------------------------
  // basic test 10: deadlock
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "deadlock" )
  begin
    init_rand_delays( 0, 0 );

    //            src   dest  opq    payload
    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce );             // Fill up input and channel queues in CCW direction
    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce );             // by sending 5 packets per router in a tornado pattern
    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce ); 
    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce );  
    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce ); 
//    init_net_msg( 3'h0, 3'h4, 8'h00, 8'hce ); 

    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );
    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );
    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );
    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );
    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );
//    init_net_msg( 3'h1, 3'h5, 8'h01, 8'hff );  

    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );
//    init_net_msg( 3'h3, 3'h6, 8'h03, 8'hc0 );

    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );
//    init_net_msg( 3'h4, 3'h7, 8'h04, 8'h55 );

    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );
//    init_net_msg( 3'h5, 3'h0, 8'h05, 8'h96 );

    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );
//    init_net_msg( 3'h6, 3'h1, 8'h06, 8'h32 );

    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );
    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );
    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );
    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );
    init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );
 //   init_net_msg( 3'h7, 3'h2, 8'h07, 8'h2e );

    run_test;
  end
  `VC_TEST_CASE_END   


  //----------------------------------------------------------------------
  // basic test 11: Tornado Random Test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "basic test 11: Tornado Random Test" )
  begin
    init_rand_delays( 0, 0 );

      //            src   dest  opq    payload
      init_net_msg( 3'h0, 3'h3, 8'h78, 8'h99 );
      init_net_msg( 3'h3, 3'h6, 8'h9c, 8'hba );
      init_net_msg( 3'h5, 3'h0, 8'hf7, 8'h54 );
      init_net_msg( 3'h2, 3'h5, 8'hab, 8'hb9 );
      init_net_msg( 3'h6, 3'h1, 8'h61, 8'h82 );
      init_net_msg( 3'h2, 3'h5, 8'hfe, 8'hf9 );
      init_net_msg( 3'h1, 3'h4, 8'h50, 8'h22 );
      init_net_msg( 3'h3, 3'h6, 8'h92, 8'h94 );
      init_net_msg( 3'h1, 3'h4, 8'hff, 8'had );
      init_net_msg( 3'h0, 3'h3, 8'h64, 8'hb0 );
      init_net_msg( 3'h1, 3'h4, 8'hf0, 8'h29 );
      init_net_msg( 3'h5, 3'h0, 8'h55, 8'h63 );
      init_net_msg( 3'h3, 3'h6, 8'h90, 8'hd2 );
      init_net_msg( 3'h1, 3'h4, 8'h15, 8'hec );
      init_net_msg( 3'h3, 3'h6, 8'h31, 8'h0c );
      init_net_msg( 3'h2, 3'h5, 8'h97, 8'hb1 );
      init_net_msg( 3'h3, 3'h6, 8'hb1, 8'h0b );
      init_net_msg( 3'h5, 3'h0, 8'h3d, 8'h4e );
      init_net_msg( 3'h1, 3'h4, 8'h70, 8'h61 );
      init_net_msg( 3'h1, 3'h4, 8'h60, 8'h94 );
      init_net_msg( 3'h2, 3'h5, 8'hf9, 8'h46 );
      init_net_msg( 3'h4, 3'h7, 8'hf8, 8'h0d );
      init_net_msg( 3'h6, 3'h1, 8'hb5, 8'h87 );
      init_net_msg( 3'h2, 3'h5, 8'h3a, 8'h1b );
      init_net_msg( 3'h7, 3'h2, 8'hd8, 8'h74 );
      init_net_msg( 3'h4, 3'h7, 8'hec, 8'hf4 );
      init_net_msg( 3'h5, 3'h0, 8'h76, 8'hfb );
      init_net_msg( 3'h3, 3'h6, 8'h27, 8'h5d );
      init_net_msg( 3'h1, 3'h4, 8'he8, 8'h2f );
      init_net_msg( 3'h5, 3'h0, 8'hd6, 8'h61 );
      init_net_msg( 3'h1, 3'h4, 8'hfc, 8'hf8 );
      init_net_msg( 3'h2, 3'h5, 8'hbb, 8'hb6 );
      init_net_msg( 3'h5, 3'h0, 8'h0e, 8'h97 );
      init_net_msg( 3'h4, 3'h7, 8'hda, 8'h87 );
      init_net_msg( 3'h4, 3'h7, 8'h1f, 8'hbb );
      init_net_msg( 3'h3, 3'h6, 8'hd7, 8'h09 );
      init_net_msg( 3'h3, 3'h6, 8'he9, 8'hbd );
      init_net_msg( 3'h5, 3'h0, 8'hd9, 8'he0 );
      init_net_msg( 3'h3, 3'h6, 8'h6c, 8'h68 );
      init_net_msg( 3'h6, 3'h1, 8'hc7, 8'hcb );
      init_net_msg( 3'h3, 3'h6, 8'hcb, 8'ha0 );
      init_net_msg( 3'h2, 3'h5, 8'h89, 8'he1 );
      init_net_msg( 3'h2, 3'h5, 8'he9, 8'h02 );
      init_net_msg( 3'h3, 3'h6, 8'h7e, 8'ha1 );
      init_net_msg( 3'h1, 3'h4, 8'hdc, 8'hca );
      init_net_msg( 3'h3, 3'h6, 8'hb9, 8'h36 );
      init_net_msg( 3'h7, 3'h2, 8'hfb, 8'hf3 );
      init_net_msg( 3'h7, 3'h2, 8'h4e, 8'hd7 );
      init_net_msg( 3'h7, 3'h2, 8'hb2, 8'h81 );
      init_net_msg( 3'h1, 3'h4, 8'h2d, 8'h1a );
      init_net_msg( 3'h3, 3'h6, 8'h3e, 8'ha7 );
      init_net_msg( 3'h3, 3'h6, 8'h7a, 8'he9 );
      init_net_msg( 3'h4, 3'h7, 8'h85, 8'h04 );
      init_net_msg( 3'h2, 3'h5, 8'hf6, 8'hcf );
      init_net_msg( 3'h0, 3'h3, 8'h5f, 8'hf7 );
      init_net_msg( 3'h1, 3'h4, 8'h7d, 8'h2d );
      init_net_msg( 3'h2, 3'h5, 8'h3e, 8'hff );
      init_net_msg( 3'h6, 3'h1, 8'h19, 8'ha0 );
      init_net_msg( 3'h4, 3'h7, 8'hf4, 8'h26 );
      init_net_msg( 3'h7, 3'h2, 8'h5e, 8'he7 );
      init_net_msg( 3'h6, 3'h1, 8'h06, 8'h93 );
      init_net_msg( 3'h0, 3'h3, 8'hc4, 8'h5e );
      init_net_msg( 3'h3, 3'h6, 8'h07, 8'hab );
      init_net_msg( 3'h5, 3'h0, 8'hc8, 8'h11 );
      init_net_msg( 3'h7, 3'h2, 8'h4a, 8'h61 );
      init_net_msg( 3'h3, 3'h6, 8'hcb, 8'h1e );
      init_net_msg( 3'h4, 3'h7, 8'hce, 8'hde );
      init_net_msg( 3'h3, 3'h6, 8'h64, 8'h2a );
      init_net_msg( 3'h1, 3'h4, 8'hb1, 8'hee );
      init_net_msg( 3'h6, 3'h1, 8'hbe, 8'h17 );
      init_net_msg( 3'h6, 3'h1, 8'h4b, 8'hf3 );
      init_net_msg( 3'h6, 3'h1, 8'h0f, 8'hcf );
      init_net_msg( 3'h7, 3'h2, 8'h4a, 8'h11 );
      init_net_msg( 3'h5, 3'h0, 8'h96, 8'h17 );
      init_net_msg( 3'h0, 3'h3, 8'hb9, 8'h8f );
      init_net_msg( 3'h5, 3'h0, 8'hda, 8'h50 );
      init_net_msg( 3'h2, 3'h5, 8'h73, 8'h2f );
      init_net_msg( 3'h1, 3'h4, 8'h40, 8'he9 );
      init_net_msg( 3'h4, 3'h7, 8'h83, 8'h90 );
      init_net_msg( 3'h1, 3'h4, 8'h9e, 8'h53 );
      init_net_msg( 3'h6, 3'h1, 8'h2d, 8'he0 );
      init_net_msg( 3'h5, 3'h0, 8'h6c, 8'h3e );
      init_net_msg( 3'h1, 3'h4, 8'h09, 8'hec );
      init_net_msg( 3'h6, 3'h1, 8'h4e, 8'h0d );
      init_net_msg( 3'h5, 3'h0, 8'h0b, 8'h46 );
      init_net_msg( 3'h2, 3'h5, 8'h0a, 8'h75 );
      init_net_msg( 3'h7, 3'h2, 8'h19, 8'hc8 );
      init_net_msg( 3'h4, 3'h7, 8'h8e, 8'h16 );
      init_net_msg( 3'h2, 3'h5, 8'hd2, 8'he9 );
      init_net_msg( 3'h4, 3'h7, 8'hef, 8'h49 );
      init_net_msg( 3'h4, 3'h7, 8'h30, 8'hc6 );
      init_net_msg( 3'h3, 3'h6, 8'h84, 8'hf7 );
      init_net_msg( 3'h5, 3'h0, 8'h11, 8'hee );
      init_net_msg( 3'h6, 3'h1, 8'hcf, 8'hdd );
      init_net_msg( 3'h3, 3'h6, 8'hce, 8'hb6 );
      init_net_msg( 3'h6, 3'h1, 8'hda, 8'he8 );
      init_net_msg( 3'h1, 3'h4, 8'had, 8'h2b );
      init_net_msg( 3'h0, 3'h3, 8'h61, 8'hc5 );
      init_net_msg( 3'h7, 3'h2, 8'h6f, 8'h7e );
      init_net_msg( 3'h1, 3'h4, 8'h8d, 8'hd1 );
      init_net_msg( 3'h2, 3'h5, 8'h34, 8'h65 );
      init_net_msg( 3'h3, 3'h6, 8'hcf, 8'h06 );
      init_net_msg( 3'h4, 3'h7, 8'h8c, 8'hd7 );
      init_net_msg( 3'h4, 3'h7, 8'h7f, 8'hd4 );
      init_net_msg( 3'h3, 3'h6, 8'hda, 8'hab );
      init_net_msg( 3'h5, 3'h0, 8'h23, 8'hde );
      init_net_msg( 3'h4, 3'h7, 8'h1f, 8'h67 );
      init_net_msg( 3'h5, 3'h0, 8'h0c, 8'h6e );
      init_net_msg( 3'h4, 3'h7, 8'h61, 8'hbf );
      init_net_msg( 3'h2, 3'h5, 8'h3f, 8'h63 );
      init_net_msg( 3'h6, 3'h1, 8'h71, 8'h3f );
      init_net_msg( 3'h1, 3'h4, 8'h8a, 8'h16 );
      init_net_msg( 3'h3, 3'h6, 8'he1, 8'hb3 );
      init_net_msg( 3'h4, 3'h7, 8'h04, 8'h6c );
      init_net_msg( 3'h7, 3'h2, 8'hf7, 8'h70 );
      init_net_msg( 3'h7, 3'h2, 8'h64, 8'h92 );
      init_net_msg( 3'h7, 3'h2, 8'h13, 8'hb9 );
      init_net_msg( 3'h1, 3'h4, 8'hc9, 8'hf1 );
      init_net_msg( 3'h4, 3'h7, 8'h0b, 8'h0f );
      init_net_msg( 3'h2, 3'h5, 8'h07, 8'hed );
      init_net_msg( 3'h3, 3'h6, 8'hfb, 8'h23 );
      init_net_msg( 3'h7, 3'h2, 8'hbe, 8'he0 );
      init_net_msg( 3'h0, 3'h3, 8'h70, 8'h56 );
      init_net_msg( 3'h4, 3'h7, 8'h39, 8'he6 );
      init_net_msg( 3'h2, 3'h5, 8'h0d, 8'hac );
      init_net_msg( 3'h1, 3'h4, 8'h6a, 8'h8e );
      init_net_msg( 3'h7, 3'h2, 8'hbf, 8'h1d );
      init_net_msg( 3'h3, 3'h6, 8'hbb, 8'h53 );
      init_net_msg( 3'h5, 3'h0, 8'hd1, 8'h9c );
      init_net_msg( 3'h1, 3'h4, 8'ha7, 8'hdd );
      init_net_msg( 3'h0, 3'h3, 8'hfc, 8'hb2 );
      init_net_msg( 3'h6, 3'h1, 8'h7b, 8'hc2 );
      init_net_msg( 3'h1, 3'h4, 8'hc9, 8'h39 );
      init_net_msg( 3'h2, 3'h5, 8'h0e, 8'h30 );
      init_net_msg( 3'h5, 3'h0, 8'h31, 8'h0d );
      init_net_msg( 3'h7, 3'h2, 8'hbd, 8'h9a );
      init_net_msg( 3'h4, 3'h7, 8'h30, 8'h90 );
      init_net_msg( 3'h1, 3'h4, 8'h29, 8'h25 );
      init_net_msg( 3'h4, 3'h7, 8'hcd, 8'h9e );
      init_net_msg( 3'h6, 3'h1, 8'h8d, 8'h76 );
      init_net_msg( 3'h7, 3'h2, 8'hdb, 8'h6d );
      init_net_msg( 3'h7, 3'h2, 8'hf7, 8'he7 );
      init_net_msg( 3'h6, 3'h1, 8'h37, 8'h2e );
      init_net_msg( 3'h0, 3'h3, 8'h2f, 8'h38 );
      init_net_msg( 3'h1, 3'h4, 8'h8f, 8'hdf );
      init_net_msg( 3'h4, 3'h7, 8'hcd, 8'h7c );
      init_net_msg( 3'h6, 3'h1, 8'h44, 8'hdf );
      init_net_msg( 3'h1, 3'h4, 8'hd0, 8'h16 );
      init_net_msg( 3'h7, 3'h2, 8'hf4, 8'h25 );
      init_net_msg( 3'h2, 3'h5, 8'h99, 8'hd6 );
      init_net_msg( 3'h3, 3'h6, 8'hb4, 8'h2d );
      init_net_msg( 3'h1, 3'h4, 8'h12, 8'hd0 );
      init_net_msg( 3'h3, 3'h6, 8'ha2, 8'h4b );
      init_net_msg( 3'h0, 3'h3, 8'hed, 8'hd8 );
      init_net_msg( 3'h0, 3'h3, 8'hbc, 8'h2b );
      init_net_msg( 3'h7, 3'h2, 8'h47, 8'hbf );
      init_net_msg( 3'h0, 3'h3, 8'hd7, 8'h2c );
      init_net_msg( 3'h7, 3'h2, 8'h95, 8'h41 );
      init_net_msg( 3'h1, 3'h4, 8'hf6, 8'h3c );
      init_net_msg( 3'h0, 3'h3, 8'ha4, 8'h9a );
      init_net_msg( 3'h4, 3'h7, 8'hdd, 8'h01 );
      init_net_msg( 3'h6, 3'h1, 8'h64, 8'ha6 );
      init_net_msg( 3'h3, 3'h6, 8'hb3, 8'h04 );
      init_net_msg( 3'h3, 3'h6, 8'hab, 8'hba );
      init_net_msg( 3'h7, 3'h2, 8'h61, 8'hfa );
      init_net_msg( 3'h4, 3'h7, 8'h0a, 8'hb0 );
      init_net_msg( 3'h3, 3'h6, 8'hbb, 8'ha6 );
      init_net_msg( 3'h3, 3'h6, 8'h0b, 8'h47 );
      init_net_msg( 3'h0, 3'h3, 8'h8f, 8'h93 );
      init_net_msg( 3'h7, 3'h2, 8'h05, 8'h26 );
      init_net_msg( 3'h4, 3'h7, 8'h50, 8'h0f );
      init_net_msg( 3'h6, 3'h1, 8'hfb, 8'h68 );
      init_net_msg( 3'h0, 3'h3, 8'he8, 8'h36 );
      init_net_msg( 3'h3, 3'h6, 8'h99, 8'hac );
      init_net_msg( 3'h7, 3'h2, 8'h7a, 8'h4f );
      init_net_msg( 3'h7, 3'h2, 8'h01, 8'hc2 );
      init_net_msg( 3'h3, 3'h6, 8'hda, 8'h2b );
      init_net_msg( 3'h7, 3'h2, 8'ha9, 8'h2d );
      init_net_msg( 3'h0, 3'h3, 8'heb, 8'h2f );
      init_net_msg( 3'h5, 3'h0, 8'h3b, 8'h04 );
      init_net_msg( 3'h2, 3'h5, 8'h73, 8'h26 );
      init_net_msg( 3'h3, 3'h6, 8'h21, 8'h95 );
      init_net_msg( 3'h3, 3'h6, 8'ha4, 8'h06 );
      init_net_msg( 3'h4, 3'h7, 8'h4b, 8'h86 );
      init_net_msg( 3'h2, 3'h5, 8'h87, 8'hf4 );
      init_net_msg( 3'h2, 3'h5, 8'h0e, 8'hee );
      init_net_msg( 3'h2, 3'h5, 8'h39, 8'h96 );
      init_net_msg( 3'h1, 3'h4, 8'h37, 8'h53 );
      init_net_msg( 3'h4, 3'h7, 8'h21, 8'h72 );
      init_net_msg( 3'h2, 3'h5, 8'ha4, 8'h76 );
      init_net_msg( 3'h3, 3'h6, 8'h73, 8'h2e );
      init_net_msg( 3'h6, 3'h1, 8'hd5, 8'he1 );
      init_net_msg( 3'h5, 3'h0, 8'hdb, 8'h97 );
      init_net_msg( 3'h6, 3'h1, 8'h3b, 8'hb0 );
      init_net_msg( 3'h7, 3'h2, 8'h38, 8'h3a );
      init_net_msg( 3'h7, 3'h2, 8'h25, 8'ha6 );
      init_net_msg( 3'h5, 3'h0, 8'h10, 8'hf3 );
      init_net_msg( 3'h1, 3'h4, 8'h5b, 8'h1e );
      init_net_msg( 3'h4, 3'h7, 8'h70, 8'hdc );
      init_net_msg( 3'h1, 3'h4, 8'h19, 8'h4b );
      init_net_msg( 3'h6, 3'h1, 8'h61, 8'h33 );
      init_net_msg( 3'h2, 3'h5, 8'hbc, 8'he5 );
      init_net_msg( 3'h4, 3'h7, 8'hb9, 8'h27 );
      init_net_msg( 3'h5, 3'h0, 8'he0, 8'hb7 );
      init_net_msg( 3'h5, 3'h0, 8'h9e, 8'h4f );
      init_net_msg( 3'h2, 3'h5, 8'heb, 8'h11 );
      init_net_msg( 3'h1, 3'h4, 8'h4f, 8'h41 );
      init_net_msg( 3'h6, 3'h1, 8'ha5, 8'hb3 );
      init_net_msg( 3'h3, 3'h6, 8'h7d, 8'h99 );
      init_net_msg( 3'h6, 3'h1, 8'h1e, 8'h49 );
      init_net_msg( 3'h3, 3'h6, 8'h17, 8'hff );
      init_net_msg( 3'h6, 3'h1, 8'hd7, 8'hba );
      init_net_msg( 3'h2, 3'h5, 8'hf8, 8'h25 );
      init_net_msg( 3'h2, 3'h5, 8'h3d, 8'hfe );
      init_net_msg( 3'h3, 3'h6, 8'hff, 8'hdb );
      init_net_msg( 3'h2, 3'h5, 8'h04, 8'h67 );
      init_net_msg( 3'h2, 3'h5, 8'hbb, 8'hc3 );
      init_net_msg( 3'h0, 3'h3, 8'h67, 8'h74 );
      init_net_msg( 3'h7, 3'h2, 8'h81, 8'h4e );
      init_net_msg( 3'h6, 3'h1, 8'h05, 8'h09 );
      init_net_msg( 3'h3, 3'h6, 8'h40, 8'h1b );
      init_net_msg( 3'h2, 3'h5, 8'he3, 8'hbc );
      init_net_msg( 3'h1, 3'h4, 8'hf8, 8'he4 );
      init_net_msg( 3'h3, 3'h6, 8'hda, 8'h1c );
      init_net_msg( 3'h4, 3'h7, 8'h90, 8'had );
      init_net_msg( 3'h0, 3'h3, 8'h4f, 8'h28 );
      init_net_msg( 3'h5, 3'h0, 8'h7b, 8'h03 );
      init_net_msg( 3'h3, 3'h6, 8'h58, 8'h9b );
      init_net_msg( 3'h3, 3'h6, 8'h5d, 8'he4 );
      init_net_msg( 3'h2, 3'h5, 8'hd7, 8'hbb );
      init_net_msg( 3'h4, 3'h7, 8'h57, 8'he6 );
      init_net_msg( 3'h7, 3'h2, 8'h0d, 8'h3f );
      init_net_msg( 3'h6, 3'h1, 8'hd6, 8'he7 );
      init_net_msg( 3'h7, 3'h2, 8'h03, 8'h41 );
      init_net_msg( 3'h2, 3'h5, 8'hd5, 8'h30 );
      init_net_msg( 3'h3, 3'h6, 8'h4c, 8'hc8 );
      init_net_msg( 3'h4, 3'h7, 8'h54, 8'h8b );
      init_net_msg( 3'h7, 3'h2, 8'h26, 8'h66 );
      init_net_msg( 3'h5, 3'h0, 8'h55, 8'h3c );
      init_net_msg( 3'h6, 3'h1, 8'h03, 8'hc3 );
      init_net_msg( 3'h1, 3'h4, 8'h18, 8'h78 );
      init_net_msg( 3'h5, 3'h0, 8'hb5, 8'h25 );
      init_net_msg( 3'h6, 3'h1, 8'hc3, 8'hfa );
      init_net_msg( 3'h7, 3'h2, 8'h17, 8'h1d );
      init_net_msg( 3'h5, 3'h0, 8'hce, 8'h34 );
      init_net_msg( 3'h3, 3'h6, 8'hfb, 8'hd0 );
      init_net_msg( 3'h7, 3'h2, 8'h53, 8'h10 );
      init_net_msg( 3'h5, 3'h0, 8'h87, 8'h10 );
      init_net_msg( 3'h2, 3'h5, 8'hc0, 8'h02 );
      init_net_msg( 3'h3, 3'h6, 8'h2a, 8'hc0 );
      init_net_msg( 3'h1, 3'h4, 8'h46, 8'hed );
      init_net_msg( 3'h3, 3'h6, 8'h34, 8'h5a );
      init_net_msg( 3'h2, 3'h5, 8'h82, 8'h54 );
      init_net_msg( 3'h5, 3'h0, 8'he1, 8'h23 );
      init_net_msg( 3'h0, 3'h3, 8'h7f, 8'h17 );
      init_net_msg( 3'h3, 3'h6, 8'h5a, 8'h5b );

      run_test;
      end
  `VC_TEST_CASE_END  

  `VC_TEST_SUITE_END
endmodule

