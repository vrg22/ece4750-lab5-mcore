//=========================================================================
// Baseline Blocking Cache
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_V

`include "vc-mem-msgs.v"
`include "vc-trace.v"
`include "lab3-mem-BlockingCacheBaseCtrl.v"
`include "lab3-mem-BlockingCacheBaseDpath.v"

module lab3_mem_BlockingCacheBase
#(
  parameter p_mem_nbytes = 256,            // Cache size in bytes
  parameter p_num_banks  = 0,              // Total number of cache banks

  // opaque field from the cache and memory side
  parameter p_opaque_nbits = 8,

  // local parameters not meant to be set from outside
  parameter dbw          = 32,             // Short name for data bitwidth
  parameter abw          = 32,             // Short name for addr bitwidth
  parameter clw          = 128,            // Short name for cacheline bitwidth

  parameter o = p_opaque_nbits
)
(
  input  logic                                        clk,
  input  logic                                        reset,

  // Cache Request

  input  logic [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0] cachereq_msg,
  input  logic                                        cachereq_val,
  output logic                                        cachereq_rdy,

  // Cache Response

  output logic [`VC_MEM_RESP_MSG_NBITS(o,dbw)-1:0]    cacheresp_msg,
  output logic                                        cacheresp_val,
  input  logic                                        cacheresp_rdy,

  // Memory Request

  output logic [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0] memreq_msg,
  output logic                                        memreq_val,
  input  logic                                        memreq_rdy,

  // Memory Response

  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]    memresp_msg,
  input  logic                                        memresp_val,
  output logic                                        memresp_rdy
);

  // calculate the index shift amount based on number of banks

  localparam c_idx_shamt = $clog2( p_num_banks );

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  lab3_mem_BlockingCacheBaseCtrl
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits)
  )
  ctrl
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

  lab3_mem_BlockingCacheBaseDpath
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits)
  )
  dpath
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

    // Tracing for init transaction states

    //case ( ctrl.state_reg )

    //  ctrl.STATE_IDLE:                   vc_trace.append_str( trace_str, "(I )" );
    //  ctrl.STATE_TAG_CHECK:              vc_trace.append_str( trace_str, "(TC)" );
    //  ctrl.STATE_INIT_DATA_ACCESS:       vc_trace.append_str( trace_str, "(IN)" );
    //  ctrl.STATE_WAIT:                   vc_trace.append_str( trace_str, "(W )" );
    //  default:                           vc_trace.append_str( trace_str, "(? )" );

    //endcase

  end
  `VC_TRACE_END

endmodule

`endif
