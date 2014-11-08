//========================================================================
// lab4-net-RouterBase     //rando
//========================================================================

`ifndef LAB4_NET_ROUTER_BASE_V
`define LAB4_NET_ROUTER_BASE_V

`include "vc-crossbars.v"
`include "vc-queues.v"
`include "vc-mem-msgs.v"
`include "vc-trace.v"

`include "lab4-net-RouterInputCtrl.v"
`include "lab4-net-RouterInputTerminalCtrl.v"
`include "lab4-net-RouterOutputCtrl.v"

module lab4_net_RouterBase
#(
  parameter p_payload_nbits  = 32,
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,

  // Shorter names, not to be set from outside the module
  parameter p = p_payload_nbits,
  parameter o = p_opaque_nbits,
  parameter s = p_srcdest_nbits,

  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s)
)
(
  input  logic                       clk,
  input  logic                       reset,

  input  logic                       in0_val,
  output logic                       in0_rdy,
  input  logic [c_net_msg_nbits-1:0] in0_msg,

  input  logic                       in1_val,
  output logic                       in1_rdy,
  input  logic [c_net_msg_nbits-1:0] in1_msg,

  input  logic                       in2_val,
  output logic                       in2_rdy,
  input  logic [c_net_msg_nbits-1:0] in2_msg,

  output logic                       out0_val,
  input  logic                       out0_rdy,
  output logic [c_net_msg_nbits-1:0] out0_msg,

  output logic                       out1_val,
  input  logic                       out1_rdy,
  output logic [c_net_msg_nbits-1:0] out1_msg,

  output logic                       out2_val,
  input  logic                       out2_rdy,
  output logic [c_net_msg_nbits-1:0] out2_msg

);

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  logic                       in0_deq_val;
  logic                       in0_deq_rdy;
  logic [c_net_msg_nbits-1:0] in0_deq_msg;

  logic                       in1_deq_val;
  logic                       in1_deq_rdy;
  logic [c_net_msg_nbits-1:0] in1_deq_msg;

  logic                       in2_deq_val;
  logic                       in2_deq_rdy;
  logic [c_net_msg_nbits-1:0] in2_deq_msg;

  //Free entry signals
  logic [1:0]                 num_free_west;
  logic [1:0]                 num_free_east;

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  // instantiate input queues, crossbar and control modules here

  //Input Queues
  vc_Queue#(`VC_QUEUE_NORMAL,c_net_msg_nbits,4) in0_queue
  (
    .clk      (clk),
    .reset    (reset),

    .enq_val  (in0_val),
    .enq_rdy  (in0_rdy),
    .enq_msg  (in0_msg),

    .deq_val  (in0_deq_val),
    .deq_rdy  (in0_deq_rdy),
    .deq_msg  (in0_deq_msg),

    .num_free_entries (num_free_west)
  );

  vc_Queue#(`VC_QUEUE_NORMAL,c_net_msg_nbits,4) in1_queue
  (
    .clk      (clk),
    .reset    (reset),

    .enq_val  (in1_val),
    .enq_rdy  (in1_rdy),
    .enq_msg  (in1_msg),

    .deq_val  (in1_deq_val),
    .deq_rdy  (in1_deq_rdy),
    .deq_msg  (in1_deq_msg),

    .num_free_entries ()
  );

  vc_Queue#(`VC_QUEUE_NORMAL,c_net_msg_nbits,4) in2_queue
  (
    .clk      (clk),
    .reset    (reset),

    .enq_val  (in2_val),
    .enq_rdy  (in2_rdy),
    .enq_msg  (in2_msg),

    .deq_val  (in2_deq_val),
    .deq_rdy  (in2_deq_rdy),
    .deq_msg  (in2_deq_msg),

    .num_free_entries (num_free_east)
  );


  //Crossbar
  logic [1:0]                 xbar_sel0;
  logic [1:0]                 xbar_sel1;
  logic [1:0]                 xbar_sel2;

  vc_Crossbar3#(c_net_msg_nbits) xbar
  (
    .in0      (in0_deq_msg),
    .in1      (in1_deq_msg),
    .in2      (in2_deq_msg),

    .sel0     (xbar_sel0),
    .sel1     (xbar_sel1),
    .sel2     (xbar_sel2),

    .out0     (out0_msg),
    .out1     (out1_msg),
    .out2     (out2_msg),
  );

  //Control Modules
  


  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  // the following is a placeholder, delete

  assign in0_rdy = 0;
  assign in1_rdy = 0;
  assign in2_rdy = 0;

  assign out0_val = 0;
  assign out1_val = 0;
  assign out2_val = 0;

  assign out0_msg = 0;
  assign out1_msg = 0;
  assign out2_msg = 0;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  logic [8*8-1:0] in0_str;
  logic [8*8-1:0] in1_str;
  logic [8*8-1:0] in2_str;

  `VC_TRACE_BEGIN
  begin

    $sformat( in0_str, "%x:%x>%x",
              in0_deq_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              in0_deq_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              in0_deq_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    $sformat( in1_str, "%x:%x>%x",
              in1_deq_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              in1_deq_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              in1_deq_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );
    $sformat( in2_str, "%x:%x>%x",
              in2_deq_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)],
              in2_deq_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)],
              in2_deq_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)] );

    vc_trace.append_str( trace_str, "(" );
    vc_trace.append_val_rdy_str( trace_str, in0_deq_val, in0_deq_rdy, in0_str );
    vc_trace.append_str( trace_str, "|" );
    vc_trace.append_val_rdy_str( trace_str, in1_deq_val, in1_deq_rdy, in1_str );
    vc_trace.append_str( trace_str, "|" );
    vc_trace.append_val_rdy_str( trace_str, in2_deq_val, in2_deq_rdy, in2_str );
    vc_trace.append_str( trace_str, ")" );
  end
  `VC_TRACE_END

endmodule
`endif /* LAB4_NET_ROUTER_BASE_V */
