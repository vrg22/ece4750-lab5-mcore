//=========================================================================
// Alternative Blocking Cache
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_V

`include "vc-mem-msgs.v"
`include "vc-trace.v"
`include "lab3-mem-BlockingCacheAltCtrl.v"
`include "lab3-mem-BlockingCacheAltDpath.v"

module lab3_mem_BlockingCacheAlt
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

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // control signals (ctrl->dpath)
  logic [1:0]                                   amo_sel;
  logic                                         cachereq_en;
  logic                                         memresp_en;
  logic                                         is_refill;
  logic                                         tag_array_0_wen;
  logic                                         tag_array_0_ren;
  logic                                         tag_array_1_wen;
  logic                                         tag_array_1_ren;
  logic                                         way_sel;
  logic                                         data_array_wen;
  logic                                         data_array_ren;
  logic [clw/8-1:0]                             data_array_wben;
  logic                                         read_data_reg_en;
  logic                                         read_tag_reg_en;
  logic [$clog2(clw/dbw)-1:0]                   read_byte_sel;
  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] memreq_type;
  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0] cacheresp_type;


  // status signals (dpath->ctrl)
  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0] cachereq_type;
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] cachereq_addr;
  logic                                             tag_match_0;
  logic                                             tag_match_1;

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  lab3_mem_BlockingCacheAltCtrl
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
//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
//    .memresp_rdy       (memresp_rdy)
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
   .memresp_rdy       (memresp_rdy),
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1)
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  lab3_mem_BlockingCacheAltDpath
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

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
//    .memresp_msg       (memresp_msg)
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
   .memresp_msg       (memresp_msg),
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1)
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
  );


  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
//     // Tracing for init transaction states
// 
//     //case ( ctrl.state_reg )
// 
//     //  ctrl.STATE_IDLE:                   vc_trace.append_str( trace_str, "(I )" );
//     //  ctrl.STATE_TAG_CHECK:              vc_trace.append_str( trace_str, "(TC)" );
//     //  ctrl.STATE_INIT_DATA_ACCESS:       vc_trace.append_str( trace_str, "(IN)" );
//     //  ctrl.STATE_WAIT:                   vc_trace.append_str( trace_str, "(W )" );
//     //  default:                           vc_trace.append_str( trace_str, "(? )" );
// 
//     //endcase
// 
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
    case ( ctrl.state_reg )

      ctrl.STATE_IDLE:                   vc_trace.append_str( trace_str, "(I )" );
      ctrl.STATE_TAG_CHECK:              vc_trace.append_str( trace_str, "(TC)" );
      ctrl.STATE_READ_DATA_ACCESS:       vc_trace.append_str( trace_str, "(RD)" );
      ctrl.STATE_WRITE_DATA_ACCESS:      vc_trace.append_str( trace_str, "(WD)" );
      ctrl.STATE_AMO_READ_DATA_ACCESS:   vc_trace.append_str( trace_str, "(AR)" );
      ctrl.STATE_AMO_WRITE_DATA_ACCESS:  vc_trace.append_str( trace_str, "(AW)" );
      ctrl.STATE_INIT_DATA_ACCESS:       vc_trace.append_str( trace_str, "(IN)" );
      ctrl.STATE_REFILL_REQUEST:         vc_trace.append_str( trace_str, "(RR)" );
      ctrl.STATE_REFILL_WAIT:            vc_trace.append_str( trace_str, "(RW)" );
      ctrl.STATE_REFILL_UPDATE:          vc_trace.append_str( trace_str, "(RU)" );
      ctrl.STATE_EVICT_PREPARE:          vc_trace.append_str( trace_str, "(EP)" );
      ctrl.STATE_EVICT_REQUEST:          vc_trace.append_str( trace_str, "(ER)" );
      ctrl.STATE_EVICT_WAIT:             vc_trace.append_str( trace_str, "(EW)" );
      ctrl.STATE_WAIT:                   vc_trace.append_str( trace_str, "(W )" );
      default:                           vc_trace.append_str( trace_str, "(? )" );

    endcase
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

  end
  `VC_TRACE_END

endmodule

`endif
