//========================================================================
// Memory Request/Response Network
//========================================================================

`ifndef LAB5_MCORE_MEM_NET_V
`define LAB5_MCORE_MEM_NET_V

`include "vc-mem-msgs.v"
`include "vc-net-msgs.v"
`include "lab5-mcore-mem-net-adapters.v"
`include "lab4-net-RingNetAlt.v"

module lab5_mcore_MemNet
#(
  parameter p_mem_opaque_nbits  = 8,
  parameter p_mem_addr_nbits    = 32,
  parameter p_mem_data_nbits    = 32,

  parameter p_num_ports         = 4,

  parameter p_single_bank       = 0,

  parameter o = p_mem_opaque_nbits,
  parameter a = p_mem_addr_nbits,
  parameter d = p_mem_data_nbits,

  parameter c_net_srcdest_nbits = $clog2(p_num_ports),
  parameter c_net_opaque_nbits  = 4,

  parameter ns = c_net_srcdest_nbits,
  parameter no = c_net_opaque_nbits,

  parameter c_req_nbits   = `VC_MEM_REQ_MSG_NBITS(o,a,d),
  parameter c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d),

  parameter rq = c_req_nbits,
  parameter rs = c_resp_nbits,

  parameter c_req_net_msg_nbits   = `VC_NET_MSG_NBITS(rq,no,ns),
  parameter c_resp_net_msg_nbits  = `VC_NET_MSG_NBITS(rs,no,ns),

  parameter nrq = c_req_net_msg_nbits,
  parameter nrs = c_resp_net_msg_nbits

)
(

  input  logic                       clk,
  input  logic                       reset,

  input  logic [rq*p_num_ports-1:0] req_in_msg,
  input  logic [p_num_ports-1:0]    req_in_val,
  output logic [p_num_ports-1:0]    req_in_rdy,

  output logic [rs*p_num_ports-1:0] resp_out_msg,
  output logic [p_num_ports-1:0]    resp_out_val,
  input  logic [p_num_ports-1:0]    resp_out_rdy,

  output logic [rq*p_num_ports-1:0] req_out_msg,
  output logic [p_num_ports-1:0]    req_out_val,
  input  logic [p_num_ports-1:0]    req_out_rdy,

  input  logic [rs*p_num_ports-1:0] resp_in_msg,
  input  logic [p_num_ports-1:0]    resp_in_val,
  output logic [p_num_ports-1:0]    resp_in_rdy

);

  logic [nrq*p_num_ports-1:0] req_net_in_msg;
  logic [nrq*p_num_ports-1:0] req_net_out_msg;
  logic [nrs*p_num_ports-1:0] resp_net_in_msg;
  logic [nrs*p_num_ports-1:0] resp_net_out_msg;

  genvar i;

  generate
    for ( i = 0; i < p_num_ports; i = i + 1 ) begin: ADAPTERS

      // proc req mem msg to net msg adapter

      lab5_mcore_MemReqMsgToNetMsg
      #(
        .p_net_src            (i),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_addr_nbits     (p_mem_addr_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits),

        .p_single_bank        (p_single_bank)
      )
      proc_mem_msg_to_net_msg
      (
        .mem_msg (req_in_msg[`VC_PORT_PICK_FIELD(rq,i)]),
        .net_msg (req_net_in_msg[`VC_PORT_PICK_FIELD(nrq,i)])
      );

      // extract the cache req mem msg from net msg payload

      vc_NetMsgUnpack #(rq,no,ns) req_net_msg_unpack
      (
        .msg      (req_net_out_msg[`VC_PORT_PICK_FIELD(nrq,i)]),
        .payload  (req_out_msg[`VC_PORT_PICK_FIELD(rq,i)])
      );

      // cache resp mem msg to net msg adapter

      lab5_mcore_MemRespMsgToNetMsg
      #(
        .p_net_src            (i),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits)
      )
      cache_mem_msg_to_net_msg
      (
        .mem_msg (resp_in_msg[`VC_PORT_PICK_FIELD(rs,i)]),
        .net_msg (resp_net_in_msg[`VC_PORT_PICK_FIELD(nrs,i)])
      );

      // extract the proc resp mem msg from net msg payload

      vc_NetMsgUnpack #(rs,no,ns) resp_net_msg_unpack
      (
        .msg      (resp_net_out_msg[`VC_PORT_PICK_FIELD(nrs,i)]),
        .payload  (resp_out_msg[`VC_PORT_PICK_FIELD(rs,i)])
      );

    end
  endgenerate

  // request network

  `define LAB4_NET_NUM_PORTS_4

  logic [p_num_ports-1:0] req_net_in_val;
  logic [p_num_ports-1:0] req_net_out_rdy;
  logic [p_num_ports-1:0] resp_net_in_val;
  logic [p_num_ports-1:0] resp_net_out_rdy;

  // for single bank mode, the cache side of things are padded to 0 other
  // than cache/mem 0

  assign req_net_in_val   = req_in_val;
  assign req_net_out_rdy  = p_single_bank ? { 32'h0, req_out_rdy[0] } :
                                            req_out_rdy;

  assign resp_net_in_val  = p_single_bank ? { 32'h0, resp_in_val[0] } :
                                            resp_in_val;
  assign resp_net_out_rdy = resp_out_rdy;

  lab4_net_RingNetAlt #(rq,no,ns,4) req_net
  (
    .clk      (clk),
    .reset    (reset),

    .in_val   (req_net_in_val),
    .in_rdy   (req_in_rdy),
    .in_msg   (req_net_in_msg),

    .out_val  (req_out_val),
    .out_rdy  (req_net_out_rdy),
    .out_msg  (req_net_out_msg)
  );

  // response network

  lab4_net_RingNetAlt #(rs,no,ns,4) resp_net
  (
    .clk      (clk),
    .reset    (reset),

    .in_val   (resp_net_in_val),
    .in_rdy   (resp_in_rdy),
    .in_msg   (resp_net_in_msg),

    .out_val  (resp_out_val),
    .out_rdy  (resp_net_out_rdy),
    .out_msg  (resp_net_out_msg)
  );



endmodule

`endif /* LAB5_MCORE_MEM_NET_V */
