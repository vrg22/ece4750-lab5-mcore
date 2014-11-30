//========================================================================
// Test Harness for lab4-net-RouterAlt
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-test.v"
`include "vc-trace.v"
`include "vc-net-msgs.v"
`include "lab4-net-RouterAlt.v"

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
  input  logic         clk,
  input  logic         reset,
  input  logic  [31:0] src_max_delay,
  input  logic  [31:0] sink_max_delay,
  output logic         done
);

  // Local parameters

  localparam c_num_routers = 8;
  localparam c_router_id   = 2;
  localparam c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s);

  // shorter names

  localparam p = p_payload_nbits;
  localparam o = p_opaque_nbits;
  localparam s = p_srcdest_nbits;

  localparam p_num_free_nbits = 3;       // 3 bits to represent 5 possible values in a 4-element queue (0,1,2,3,4)
  localparam f                = 2;       // bits to represent 3 possible values of channel free entries


  //----------------------------------------------------------------------
  // Test sources
  //----------------------------------------------------------------------

  logic                       src0_val;
  logic                       src0_rdy;
  logic [c_net_msg_nbits-1:0] src0_msg;
  logic                       src0_done;

  logic                       src1_val;
  logic                       src1_rdy;
  logic [c_net_msg_nbits-1:0] src1_msg;
  logic                       src1_done;

  logic                       src2_val;
  logic                       src2_rdy;
  logic [c_net_msg_nbits-1:0] src2_msg;
  logic                       src2_done;


  vc_TestRandDelaySource#(c_net_msg_nbits) src0
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (src_max_delay),
    .val        (src0_val),
    .rdy        (src0_rdy),
    .msg        (src0_msg),
    .done       (src0_done)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src1
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (src_max_delay),
    .val        (src1_val),
    .rdy        (src1_rdy),
    .msg        (src1_msg),
    .done       (src1_done)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src2
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (src_max_delay),
    .val        (src2_val),
    .rdy        (src2_rdy),
    .msg        (src2_msg),
    .done       (src2_done)
  );

  //----------------------------------------------------------------------
  // Router under test
  //----------------------------------------------------------------------

  logic                       sink0_val;
  logic                       sink0_rdy;
  logic [c_net_msg_nbits-1:0] sink0_msg;

  logic                       sink1_val;
  logic                       sink1_rdy;
  logic [c_net_msg_nbits-1:0] sink1_msg;

  logic                       sink2_val;
  logic                       sink2_rdy;
  logic [c_net_msg_nbits-1:0] sink2_msg;

  logic [f-1:0]               forw_free_one;
  logic [f-1:0]               forw_free_two;
  logic [f-1:0]               backw_free_one;
  logic [f-1:0]               backw_free_two;


  lab4_net_RouterAlt
  #(
    .p_payload_nbits  (p_payload_nbits),
    .p_opaque_nbits   (p_opaque_nbits),
    .p_srcdest_nbits  (p_srcdest_nbits),

    .p_router_id      (c_router_id),
    .p_num_routers    (c_num_routers),

    .p_num_free_nbits (p_num_free_nbits),
    .f                (f)
  )
  router
  (
    .clk              (clk),
    .reset            (reset),

    .in0_val          (src0_val),
    .in0_rdy          (src0_rdy),
    .in0_msg          (src0_msg),

    .in1_val          (src1_val),
    .in1_rdy          (src1_rdy),
    .in1_msg          (src1_msg),

    .in2_val          (src2_val),
    .in2_rdy          (src2_rdy),
    .in2_msg          (src2_msg),

    .out0_val         (sink0_val),
    .out0_rdy         (sink0_rdy),
    .out0_msg         (sink0_msg),

    .out1_val         (sink1_val),
    .out1_rdy         (sink1_rdy),
    .out1_msg         (sink1_msg),

    .out2_val         (sink2_val),
    .out2_rdy         (sink2_rdy),
    .out2_msg         (sink2_msg),

    .forw_free_one    (forw_free_one),
    .forw_free_two    (forw_free_two),
    .backw_free_one   (backw_free_one),
    .backw_free_two   (backw_free_two)
  );

  //----------------------------------------------------------------------
  // Test sinks
  //----------------------------------------------------------------------

  logic sink0_done;
  logic sink1_done;
  logic sink2_done;

  // We use unordered sinks because the messages can come out of order

  vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink0
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink0_val),
    .rdy        (sink0_rdy),
    .msg        (sink0_msg),
    .done       (sink0_done)
  );

  vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink1
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink1_val),
    .rdy        (sink1_rdy),
    .msg        (sink1_msg),
    .done       (sink1_done)
  );

  vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink2
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink2_val),
    .rdy        (sink2_rdy),
    .msg        (sink2_msg),
    .done       (sink2_done)
  );


  // Done when all of sources and sinks are done

  assign done = src0_done  && src1_done  && src2_done  &&
                sink0_done && sink1_done && sink2_done;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [8*8-1:0] src0_str;
  logic [8*8-1:0] src1_str;
  logic [8*8-1:0] src2_str;

  logic [8*8-1:0] sink0_str;
  logic [8*8-1:0] sink1_str;
  logic [8*8-1:0] sink2_str;

  `VC_TRACE_BEGIN
  begin

    $sformat( src0_str, "%x:%x>%x",
              src0_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              src0_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              src0_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, src0_val, src0_rdy, src0_str );

    vc_trace.append_str( trace_str, "|" );

    $sformat( src1_str, "%x:%x>%x",
              src1_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              src1_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              src1_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, src1_val, src1_rdy, src1_str );

    vc_trace.append_str( trace_str, "|" );

    $sformat( src2_str, "%x:%x>%x",
              src2_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              src2_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              src2_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, src2_val, src2_rdy, src2_str );

    vc_trace.append_str( trace_str, " > " );

    router.trace( trace_str );

    vc_trace.append_str( trace_str, " > " );

    $sformat( sink0_str, "%x:%x>%x",
              sink0_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              sink0_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              sink0_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, sink0_val, sink0_rdy, sink0_str );

    vc_trace.append_str( trace_str, "|" );

    $sformat( sink1_str, "%x:%x>%x",
              sink1_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              sink1_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              sink1_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, sink1_val, sink1_rdy, sink1_str );

    vc_trace.append_str( trace_str, "|" );

    $sformat( sink2_str, "%x:%x>%x",
              sink2_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              sink2_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              sink2_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    vc_trace.append_val_rdy_str( trace_str, sink2_val, sink2_rdy, sink2_str );

  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "lab4-net-RouterAlt" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Local parameters

  localparam p_num_ports     = 8;

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

  logic [10:0] th_src_index  [2:0];
  logic [10:0] th_sink_index [2:0];

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
    // we also reset the src/sink indexes and put x's in index 0
    th_src_index[0] = 0;
    th_src_index[1] = 0;
    th_src_index[2] = 0;
    th_sink_index[0] = 0;
    th_sink_index[1] = 0;
    th_sink_index[2] = 0;

    th.src0.src.m[0] = 'hx;
    th.src1.src.m[0] = 'hx;
    th.src2.src.m[0] = 'hx;
    th.sink0.sink.m[0] = 'hx;
    th.sink1.sink.m[0] = 'hx;
    th.sink2.sink.m[0] = 'hx;

    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask


  task init_src
  (
    input logic [31:0]   port,

    input logic [c_net_msg_nbits-1:0] msg
  );
  begin

    case ( port )
      0: begin
        th.src0.src.m[ th_src_index[port] ] = msg;

        // we load xs for the next address so that src/sink messages don't
        // bleed to the next one

        th.src0.src.m[ th_src_index[port] + 1] = 'hx;
      end
      1: begin
        th.src1.src.m[ th_src_index[port] ] = msg;

        // we load xs for the next address so that src/sink messages don't
        // bleed to the next one

        th.src1.src.m[ th_src_index[port] + 1] = 'hx;
      end
      2: begin
        th.src2.src.m[ th_src_index[port] ] = msg;

        // we load xs for the next address so that src/sink messages don't
        // bleed to the next one

        th.src2.src.m[ th_src_index[port] + 1] = 'hx;
      end
    endcase

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

    case ( port )
      0: begin
        th.sink0.sink.m[ th_sink_index[port] ] = msg;

        // we load xs for the next address so that sink/sink messages don't
        // bleed to the next one

        th.sink0.sink.m[ th_sink_index[port] + 1] = 'hx;
      end
      1: begin
        th.sink1.sink.m[ th_sink_index[port] ] = msg;

        // we load xs for the next address so that sink/sink messages don't
        // bleed to the next one

        th.sink1.sink.m[ th_sink_index[port] + 1] = 'hx;
      end
      2: begin
        th.sink2.sink.m[ th_sink_index[port] ] = msg;

        // we load xs for the next address so that sink/sink messages don't
        // bleed to the next one

        th.sink2.sink.m[ th_sink_index[port] + 1] = 'hx;
      end
    endcase

    // increment the index
    th_sink_index[port] = th_sink_index[port] + 1;

  end
  endtask


  logic [c_net_msg_nbits-1:0] th_port_msg;

  task init_net_msg
  (
    input logic [1:0]                                  in_port,
    input logic [1:0]                                  out_port,

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

    init_src(  in_port,  th_port_msg );
    init_sink( out_port, th_port_msg );

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.vc_trace.cycles < 500) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // basic test 1: send a message to self
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test 1: send a message to self" )
  begin
    init_rand_delays( 0, 0 );

    // Send a message to self

    //            port  port
    //            in    out   src   dest  opq    payload
    init_net_msg( 2'h1, 2'h1, 3'h2, 3'h2, 8'h00, 8'hce );

    run_test;

  end
  `VC_TEST_CASE_END


  // add more test cases

  //----------------------------------------------------------------------
  // basic test 2: send a message east, dest-src less than 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test 2: send a message east, dest-src less than 4" )
  begin
    init_rand_delays( 0, 0 );

    //            port  port
    //            in    out   src   dest  opq    payload
    init_net_msg( 2'h2, 2'h2, 3'h0, 3'h4, 8'h00, 8'hff );      // tests "extreme case" of sending from 7 to 0 CCW 

    run_test;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test 3: send a message west, dest-src less than 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test 3: send a message west, dest-src less than 4" )
  begin
    init_rand_delays( 0, 0 );

    //            port  port
    //            in    out   src   dest  opq    payload
    init_net_msg( 2'h0, 2'h0, 3'h4, 3'h1, 8'h00, 8'hab );     // tests "extreme case" of sending from 0 to 7 CW 

    run_test;

  end
  `VC_TEST_CASE_END

  /* //----------------------------------------------------------------------
  // basic test 4: send a message east, dest-src greater than 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "basic test 4: send a message east, dest-src greater than than 4" )                   // CHANGE ROUTER ID TO 0 FOR BASIC TEST 4
  begin
    init_rand_delays( 0, 0 );

    //            port  port
    //            in    out   src   dest  opq    payload
    init_net_msg( 2'h0, 2'h1, 3'h7, 3'h0, 8'h00, 8'hab );     // tests "extreme case" of sending from 7 to 0 CW 

    run_test;

  end
  `VC_TEST_CASE_END */

  /* //----------------------------------------------------------------------
  // basic test 5: send a message west, dest-src greater than 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "basic test 5: send a message west, dest-src greater than than 4" )                   // CHANGE ROUTER ID TO 7 FOR BASIC TEST 5
  begin
    init_rand_delays( 0, 0 );

    //            port  port
    //            in    out   src   dest  opq    payload
    init_net_msg( 2'h2, 2'h1, 3'h0, 3'h7, 8'h00, 8'hab );     // tests "extreme case" of sending from 0 to 7 CW 

    run_test;

  end
  `VC_TEST_CASE_END */


  // add more test cases

  `VC_TEST_SUITE_END
endmodule

