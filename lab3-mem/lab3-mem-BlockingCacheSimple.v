//=========================================================================
// Simple Cache
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_SIMPLE_V
`define LAB3_MEM_BLOCKING_CACHE_SIMPLE_V

`include "vc-mem-msgs.v"
`include "vc-trace.v"

`include "lab3-mem-BlockingCacheSimpleCtrl.v"
`include "lab3-mem-BlockingCacheSimpleDpath.v"


module lab3_mem_BlockingCacheSimple
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

  // control signals (ctrl->dpath)

  // add the control signal wires here

  // status signals (dpath->ctrl)

  // add the status signal wires here

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  lab3_mem_BlockingCacheSimpleCtrl ctrl
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_val      (cachereq_val),
   .cachereq_rdy      (cachereq_rdy),

   // Cache Response

   .cacheresp_val     (cacheresp_val),
   .cacheresp_rdy     (cacheresp_rdy),

   // Memory Request

   .memreq_val        (memreq_val),
   .memreq_rdy        (memreq_rdy),

   // Memory Response

   .memresp_val       (memresp_val),
   .memresp_rdy       (memresp_rdy)

  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  lab3_mem_BlockingCacheSimpleDpath#(p_mem_nbytes) dpath
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_msg      (cachereq_msg),

   // Cache Response

   .cacheresp_msg     (cacheresp_msg),

   // Memory Request

   .memreq_msg        (memreq_msg),

   // Memory Response

   .memresp_msg       (memresp_msg)

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
