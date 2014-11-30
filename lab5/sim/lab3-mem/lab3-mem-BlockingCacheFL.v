//=========================================================================
// Functional Level Blocking Cache
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_FL_V
`define LAB3_MEM_BLOCKING_CACHE_FL_V

`include "vc-mem-msgs.v"
`include "vc-trace.v"

module lab3_mem_BlockingCacheFL
#(
  parameter p_mem_nbytes = 256,            // Cache size in bytes

  // local parameters not meant to be set from outside
  parameter dbw          = 32,             // Short name for data bitwidth
  parameter abw          = 32,             // Short name for addr bitwidth
  parameter clw          = 128             // Short name for cacheline bitwidth
)
(
  input  logic                                        clk,
  input  logic                                        reset,

  // Cache Request

  input  logic [`VC_MEM_REQ_MSG_NBITS(8,abw,dbw)-1:0] cachereq_msg,
  input  logic                                        cachereq_val,
  output logic                                        cachereq_rdy,

  // Cache Response

  output logic [`VC_MEM_RESP_MSG_NBITS(8,dbw)-1:0]    cacheresp_msg,
  output logic                                        cacheresp_val,
  input  logic                                        cacheresp_rdy,

  // Memory Request

  output logic [`VC_MEM_REQ_MSG_NBITS(8,abw,clw)-1:0] memreq_msg,
  output logic                                        memreq_val,
  input  logic                                        memreq_rdy,

  // Memory Response

  input  logic [`VC_MEM_RESP_MSG_NBITS(8,clw)-1:0]    memresp_msg,
  input  logic                                        memresp_val,
  output logic                                        memresp_rdy
);

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // cache request

  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(8,abw,dbw)-1:0]   cachereq_type;
  logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,abw,dbw)-1:0] cachereq_opaque;
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(8,abw,dbw)-1:0]   cachereq_addr;
  logic [`VC_MEM_REQ_MSG_LEN_NBITS(8,abw,dbw)-1:0]    cachereq_len;
  logic [`VC_MEM_REQ_MSG_DATA_NBITS(8,abw,dbw)-1:0]   cachereq_data;

  // memory response

  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(8,clw)-1:0]      memresp_type;
  logic [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,clw)-1:0]    memresp_opaque;
  logic [`VC_MEM_RESP_MSG_LEN_NBITS(8,clw)-1:0]       memresp_len;
  logic [`VC_MEM_RESP_MSG_DATA_NBITS(8,clw)-1:0]      memresp_data;

  // memory request

  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(8,abw,clw)-1:0]   memreq_type;
  logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,abw,clw)-1:0] memreq_opaque;
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(8,abw,clw)-1:0]   memreq_addr;
  logic [`VC_MEM_REQ_MSG_LEN_NBITS(8,abw,clw)-1:0]    memreq_len;
  logic [`VC_MEM_REQ_MSG_DATA_NBITS(8,abw,clw)-1:0]   memreq_data;

  // cache response

  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(8,dbw)-1:0]      cacheresp_type;
  logic [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,dbw)-1:0]    cacheresp_opaque;
  logic [`VC_MEM_RESP_MSG_LEN_NBITS(8,dbw)-1:0]       cacheresp_len;
  logic [`VC_MEM_RESP_MSG_DATA_NBITS(8,dbw)-1:0]      cacheresp_data;

  //----------------------------------------------------------------------
  // Unpack
  //----------------------------------------------------------------------

  // Unpack cache request

  vc_MemReqMsgUnpack#(8,abw,dbw) cachereq_msg_unpack
  (
    // input

    .msg    (cachereq_msg),

    // outputs

    .type_  (cachereq_type),
    .opaque (cachereq_opaque),
    .addr   (cachereq_addr),
    .len    (cachereq_len),
    .data   (cachereq_data)
  );

  // Unpack memory response

  vc_MemRespMsgUnpack#(8,clw) memresp_msg_unpack
  (
    // input

    .msg    (memresp_msg),

    // outputs

    .type_  (memresp_type),
    .opaque (memresp_opaque),
    .len    (memresp_len),
    .data   (memresp_data)
  );

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  // pass through the request and response signals

  assign memreq_val    = cachereq_val;
  assign cachereq_rdy  = memreq_rdy;

  assign cacheresp_val = memresp_val;
  assign memresp_rdy   = cacheresp_rdy;

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  // pass the transaction to main memory

  assign memreq_type      = cachereq_type;
  assign memreq_opaque    = cachereq_opaque;
  assign memreq_addr      = cachereq_addr;
  assign memreq_len       = cachereq_len == 0 ? 3'b100 : cachereq_len;
  assign memreq_data      = cachereq_data;

  // pass the transaction to the processor

  assign cacheresp_type   = memresp_type;
  assign cacheresp_opaque = memresp_opaque;
  assign cacheresp_len    = memresp_len;
  assign cacheresp_data   = memresp_data;

  //----------------------------------------------------------------------
  // Pack
  //----------------------------------------------------------------------

  // Pack cache response

  vc_MemRespMsgPack#(8,dbw) cacheresp_msg_pack
  (
    // inputs

    .type_  (cacheresp_type),
    .opaque (cacheresp_opaque),
    .len    (cacheresp_len),
    .data   (cacheresp_data),

    // output

    .msg    (cacheresp_msg)
  );

  // Pack memory request

  vc_MemReqMsgPack#(8,abw,clw) memreq_msg_pack
  (
    // inputs

    .type_  (memreq_type),
    .opaque (memreq_opaque),
    .addr   (memreq_addr),
    .len    (memreq_len),
    .data   (memreq_data),

    // output

    .msg    (memreq_msg)
  );

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin

    // add line tracing here

    vc_trace.append_str( trace_str, "forw" );

  end
  `VC_TRACE_END

endmodule

`endif
