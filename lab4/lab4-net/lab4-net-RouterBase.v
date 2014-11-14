//========================================================================
// lab4-net-RouterBase
//========================================================================

`ifndef LAB4_NET_ROUTER_BASE_V
`define LAB4_NET_ROUTER_BASE_V

`include "vc-crossbars.v"
`include "vc-queues.v"
`include "vc-net-msgs.v"
// `include "vc-mem-msgs.v"
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

  // Free entry signals - NOTE the extra bit in each to allow it to represent 
  // the n+1 possible values in an n-element queue
  logic [2:0]                 num_free_west;
  logic [2:0]                 num_free_east;

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
    .out2     (out2_msg)
  );

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  //Wires
  logic [s-1:0]               dest0;
  logic [s-1:0]               dest1;
  logic [s-1:0]               dest2;

  //Grant & Request wires
  logic [2:0]                 in_reqs0;
  logic [2:0]                 in_reqs1;
  logic [2:0]                 in_reqs2;

  logic [2:0]                 out_reqs0;
  logic [2:0]                 out_reqs1;
  logic [2:0]                 out_reqs2;

  logic [2:0]                 in_grants0;
  logic [2:0]                 in_grants1;
  logic [2:0]                 in_grants2;

  logic [2:0]                 out_grants0;
  logic [2:0]                 out_grants1;
  logic [2:0]                 out_grants2;

  //Assignment
  assign out_reqs0 = {in_reqs2[0], in_reqs1[0], in_reqs0[0]};
  assign out_reqs1 = {in_reqs2[1], in_reqs1[1], in_reqs0[1]};
  assign out_reqs2 = {in_reqs2[2], in_reqs1[2], in_reqs0[2]};

  assign in_grants0 = {out_grants2[0], out_grants1[0], out_grants0[0]};
  assign in_grants1 = {out_grants2[1], out_grants1[1], out_grants0[1]};
  assign in_grants2 = {out_grants2[2], out_grants1[2], out_grants0[2]};


  //Unpack Network Msgs -> OR do we want to manually bitslice here?
  vc_NetMsgUnpack#(p,o,s) in0_deq_unpack
  (
    .msg      (in0_deq_msg),

    .dest     (dest0)
    // .src      (),
    // .opaque   (),
    // .payload  ()   
  );

  vc_NetMsgUnpack#(p,o,s) in1_deq_unpack
  (
    .msg      (in1_deq_msg),

    .dest     (dest1)
    // .src      (),
    // .opaque   (),
    // .payload  ()   
  );

  vc_NetMsgUnpack#(p,o,s) in2_deq_unpack
  (
    .msg      (in2_deq_msg),

    .dest     (dest2)
    // .src      (),
    // .opaque   (),
    // .payload  ()   
  );


  //Input Control Units (2 InputCtrl, 1 InputTerminalCtrl)
  lab4_net_RouterInputCtrl#(p_router_id, p_num_routers) in0_ctrl //West_Input_Port (GOING west) //CHECK!
  (
    .dest     (dest0),

    .in_val   (in0_deq_val),
    .in_rdy   (in0_deq_rdy),

    .reqs     (in_reqs0),
    .grants   (in_grants0)
  );

  lab4_net_RouterInputCtrl#(p_router_id, p_num_routers) in2_ctrl //East_Input_Port (GOING east) //CHECK!
  (
    .dest     (dest2),

    .in_val   (in2_deq_val),
    .in_rdy   (in2_deq_rdy),

    .reqs     (in_reqs2),
    .grants   (in_grants2)
  );

  lab4_net_RouterInputTerminalCtrl#(p_router_id, p_num_routers, 3 /*Free bits = 2 or 3?*/) in1_ctrl //Input/Output Terminal Port
  (
    .dest               (dest1),

    .in_val             (in1_deq_val),
    .in_rdy             (in1_deq_rdy),

    .num_free_west      (num_free_west),
    .num_free_east      (num_free_east),

    .reqs               (in_reqs1),
    .grants             (in_grants1)
  );

  //Output Control Units (3 identical units)
  lab4_net_RouterOutputCtrl out0_ctrl
  (
    .clk          (clk),
    .reset        (reset),

    .reqs         (out_reqs0),
    .grants       (out_grants0),

    .out_val      (out0_val),
    .out_rdy      (out0_rdy),
    .xbar_sel     (xbar_sel0)
  );

  lab4_net_RouterOutputCtrl out1_ctrl
  (
    .clk          (clk),
    .reset        (reset),

    .reqs         (out_reqs1),
    .grants       (out_grants1),

    .out_val      (out1_val),
    .out_rdy      (out1_rdy),
    .xbar_sel     (xbar_sel1)
  );

  lab4_net_RouterOutputCtrl out2_ctrl
  (
    .clk          (clk),
    .reset        (reset),

    .reqs         (out_reqs2),
    .grants       (out_grants2),

    .out_val      (out2_val),
    .out_rdy      (out2_rdy),
    .xbar_sel     (xbar_sel2)
  );

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
