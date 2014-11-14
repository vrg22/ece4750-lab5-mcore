//========================================================================
// lab4-net-RingNetAlt
//========================================================================

`ifndef LAB4_NET_RING_NET_ALT
`define LAB4_NET_RING_NET_ALT

`include "vc-net-msgs.v"
`include "vc-param-utils.v"
`include "vc-queues.v"
`include "vc-trace.v"

`include "lab4-net-RouterAlt.v"

// macros to calculate previous and next router ids

`define PREV(i_)  ( ( i_ + c_num_ports - 1 ) % c_num_ports )
`define NEXT(i_)  i_

module lab4_net_RingNetAlt
#(
  parameter p_payload_nbits  = 32,
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  // Shorter names, not to be set from outside the module
  parameter p = p_payload_nbits,
  parameter o = p_opaque_nbits,
  parameter s = p_srcdest_nbits,

  parameter c_num_ports = 8,
  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s),

  parameter m = c_net_msg_nbits,
  parameter f = 2                                             // bits to represent 3 possible values of channel free entries
)
(
  input  logic clk,
  input  logic reset,

  input  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] in_val,
  output logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] in_rdy,
  input  logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] in_msg,

  output logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] out_val,
  input  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] out_rdy,
  output logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] out_msg
);


  //----------------------------------------------------------------------
  // Router-Congestion Pipeline connection wires
  //----------------------------------------------------------------------

  // forward (increasing router id) wires

  logic [`VC_PORT_PICK_NBITS(f,c_num_ports)-1:0] forw_free_input;             // from congestion pipe to router
  logic [`VC_PORT_PICK_NBITS(f,c_num_ports)-1:0] forw_free_output;            // from channel to congestion pipe

  // backward (decreasing router id) wires

  logic [`VC_PORT_PICK_NBITS(f,c_num_ports)-1:0] backw_free_input;
  logic [`VC_PORT_PICK_NBITS(f,c_num_ports)-1:0] backw_free_output;


  //----------------------------------------------------------------------
  // Router-router connection wires
  //----------------------------------------------------------------------

  // forward (increasing router id) wires

  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] forw_out_val;
  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] forw_out_rdy;
  logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] forw_out_msg;

  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] forw_in_val;
  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] forw_in_rdy;
  logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] forw_in_msg;

  // backward (decreasing router id) wires

  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] backw_out_val;
  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] backw_out_rdy;
  logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] backw_out_msg;

  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] backw_in_val;
  logic [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0] backw_in_rdy;
  logic [`VC_PORT_PICK_NBITS(m,c_num_ports)-1:0] backw_in_msg;

  //----------------------------------------------------------------------
  // Router generation
  //----------------------------------------------------------------------

  genvar i;

  generate
    for ( i = 0; i < c_num_ports; i = i + 1 ) begin: ROUTER

      lab4_net_RouterAlt
      #(
        .p_payload_nbits  (p_payload_nbits),
        .p_opaque_nbits   (p_opaque_nbits),
        .p_srcdest_nbits  (p_srcdest_nbits),

        .p_router_id      (i),
        .p_num_routers    (c_num_ports)
      )
      router
      (
        .clk      (clk),
        .reset    (reset),

        .in0_val  (forw_in_val[`VC_PORT_PICK_FIELD(1,`PREV(i))]),
        .in0_rdy  (forw_in_rdy[`VC_PORT_PICK_FIELD(1,`PREV(i))]),
        .in0_msg  (forw_in_msg[`VC_PORT_PICK_FIELD(m,`PREV(i))]),

        .in1_val  (in_val[`VC_PORT_PICK_FIELD(1,i)]),
        .in1_rdy  (in_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .in1_msg  (in_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .in2_val  (backw_in_val[`VC_PORT_PICK_FIELD(1,`NEXT(i))]),
        .in2_rdy  (backw_in_rdy[`VC_PORT_PICK_FIELD(1,`NEXT(i))]),
        .in2_msg  (backw_in_msg[`VC_PORT_PICK_FIELD(m,`NEXT(i))]),

        .out0_val (backw_out_val[`VC_PORT_PICK_FIELD(1,`PREV(i))]),
        .out0_rdy (backw_out_rdy[`VC_PORT_PICK_FIELD(1,`PREV(i))]),
        .out0_msg (backw_out_msg[`VC_PORT_PICK_FIELD(m,`PREV(i))]),

        .out1_val (out_val[`VC_PORT_PICK_FIELD(1,i)]),
        .out1_rdy (out_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .out1_msg (out_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .out2_val (forw_out_val[`VC_PORT_PICK_FIELD(1,`NEXT(i))]),
        .out2_rdy (forw_out_rdy[`VC_PORT_PICK_FIELD(1,`NEXT(i))]),
        .out2_msg (forw_out_msg[`VC_PORT_PICK_FIELD(m,`NEXT(i))]),

        .forw_free_one  (),                                                   //  FILL IN WITH OUTPUTS FROM MODULE
        .forw_free_two  (),
        .backw_free_one (),
        .backw_free_two ()
      );


    end
  endgenerate

  //----------------------------------------------------------------------
  // Channel generation
  //----------------------------------------------------------------------

  generate
    for ( i = 0; i < c_num_ports; i = i + 1 ) begin: CHANNEL

      vc_Queue
      #(
        .p_type       (`VC_QUEUE_NORMAL),
        .p_msg_nbits  (c_net_msg_nbits),
        .p_num_msgs   (2)
      )
      forw_channel_queue
      (
        .clk      (clk),
        .reset    (reset),

        .enq_val  (forw_out_val[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_rdy  (forw_out_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_msg  (forw_out_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .deq_val  (forw_in_val[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_rdy  (forw_in_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_msg  (forw_in_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .num_free_entries (forw_free_output[`VC_PORT_PICK_FIELD(f,i)])
      );

      vc_Queue
      #(
        .p_type       (`VC_QUEUE_NORMAL),
        .p_msg_nbits  (c_net_msg_nbits),
        .p_num_msgs   (2)
      )
      backw_channel_queue
      (
        .clk      (clk),
        .reset    (reset),

        .enq_val  (backw_out_val[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_rdy  (backw_out_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_msg  (backw_out_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .deq_val  (backw_in_val[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_rdy  (backw_in_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_msg  (backw_in_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .num_free_entries (backw_free_output[`VC_PORT_PICK_FIELD(f,i)])
      );

    end
  endgenerate


  //----------------------------------------------------------------------
  // Channel generation
  //----------------------------------------------------------------------

  generate
    for ( i = 0; i < c_num_ports; i = i + 1 ) begin: CHANNEL

      //  INSERT CONGESTION MODULE HERE

      vc_Queue
      #(
        .p_type       (`VC_QUEUE_NORMAL),
        .p_msg_nbits  (c_net_msg_nbits),
        .p_num_msgs   (2)
      )
      backw_channel_queue
      (
        .clk      (clk),
        .reset    (reset),

        .enq_val  (backw_out_val[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_rdy  (backw_out_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .enq_msg  (backw_out_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .deq_val  (backw_in_val[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_rdy  (backw_in_rdy[`VC_PORT_PICK_FIELD(1,i)]),
        .deq_msg  (backw_in_msg[`VC_PORT_PICK_FIELD(m,i)]),

        .num_free_entries (backw_free_output[`VC_PORT_PICK_FIELD(f,i)])
      );

    end
  endgenerate




  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin
    ROUTER[0].router.trace( trace_str );
    ROUTER[1].router.trace( trace_str );
    ROUTER[2].router.trace( trace_str );
    ROUTER[3].router.trace( trace_str );
    ROUTER[4].router.trace( trace_str );
    ROUTER[5].router.trace( trace_str );
    ROUTER[6].router.trace( trace_str );
    ROUTER[7].router.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

`endif /* LAB4_NET_RING_NET_ALT */
