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

  // Left to Right Signals 
  logic           memresp_en;
  logic           cachereq_en;
  logic [2:0]     cachereq_type;
  logic [abw-1:0] cachereq_addr;
  
  logic           write_data_mux_sel;
  logic           tag_array_ren;
  logic           tag_array0_wen;
  logic           tag_array1_wen;
  logic           data_array_ren;
  logic           data_array0_wen;
  logic           data_array1_wen;
  logic [15:0]    data_array_wben;
  logic           read_data_reg_en;

  logic           tag0_match;
  logic           tag1_match;

  logic           evict_addr_reg_en;
  logic [2:0]     read_word_mux_sel;
  logic           memreq_addr_mux_sel;
  
  logic [2:0]     cacheresp_type;
  logic [2:0]     memreq_type;
  logic           way_sel;

  
  
  


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
   .memresp_rdy       (memresp_rdy),

   
   .memresp_en          (memresp_en),
   .cachereq_en         (cachereq_en),
   .cachereq_type       (cachereq_type),
   .cachereq_addr       (cachereq_addr),

   .write_data_mux_sel  (write_data_mux_sel),
   .tag_array_ren       (tag_array_ren),
   .tag_array0_wen      (tag_array0_wen),
   .tag_array1_wen      (tag_array1_wen),

   .data_array_ren      (data_array_ren),
   .data_array0_wen     (data_array0_wen),
   .data_array1_wen     (data_array1_wen),
   .data_array_wben     (data_array_wben),
   .read_data_reg_en    (read_data_reg_en),

   .tag0_match          (tag0_match),
   .tag1_match          (tag1_match),

   .evict_addr_reg_en   (evict_addr_reg_en),
   .read_word_mux_sel   (read_word_mux_sel),
   .memreq_addr_mux_sel (memreq_addr_mux_sel),

   .cacheresp_type      (cacheresp_type),
   .memreq_type         (memreq_type),
   .way_sel             (way_sel)
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
   .clk                 (clk),
   .reset               (reset),
  
   // Cache Request 
   .cachereq_msg        (cachereq_msg),
  
   // Cache Response  
   .cacheresp_msg       (cacheresp_msg),
  
   // Memory Request  
   .memreq_msg          (memreq_msg),
  
   // Memory Response 
   .memresp_msg         (memresp_msg),
  
   .memresp_en          (memresp_en),
   .cachereq_en         (cachereq_en),
   .cachereq_type       (cachereq_type),
   .cachereq_addr       (cachereq_addr),

   .write_data_mux_sel  (write_data_mux_sel),
   .tag_array_ren       (tag_array_ren),
   .tag_array0_wen      (tag_array0_wen),
   .tag_array1_wen      (tag_array1_wen),

   .data_array_ren      (data_array_ren),
   .data_array0_wen     (data_array0_wen),
   .data_array1_wen     (data_array1_wen),
   .data_array_wben     (data_array_wben),
   .read_data_reg_en    (read_data_reg_en),

   .tag0_match          (tag0_match),
   .tag1_match          (tag1_match),

   .evict_addr_reg_en   (evict_addr_reg_en),
   .read_word_mux_sel   (read_word_mux_sel),
   .memreq_addr_mux_sel (memreq_addr_mux_sel),

   .cacheresp_type      (cacheresp_type),
   .memreq_type         (memreq_type),
   .way_sel             (way_sel)
  );


  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `VC_TRACE_BEGIN
  begin

    // Tracing for init transaction states

    case ( ctrl.state_reg )

      ctrl.STATE_IDLE:                   vc_trace.append_str( trace_str, "(I )" );
      ctrl.STATE_TAG_CHECK:              vc_trace.append_str( trace_str, "(TC)" );
      ctrl.STATE_INIT_DATA_ACCESS:       vc_trace.append_str( trace_str, "(IN)" );
      ctrl.STATE_WAIT:                   vc_trace.append_str( trace_str, "(W )" );
      ctrl.STATE_READ_DATA_ACCESS:       vc_trace.append_str( trace_str, "(RD)" );
      ctrl.STATE_WRITE_DATA_ACCESS:      vc_trace.append_str( trace_str, "(WD)" );
      ctrl.STATE_REFILL_REQUEST:         vc_trace.append_str( trace_str, "(RR)" );
      ctrl.STATE_REFILL_WAIT:            vc_trace.append_str( trace_str, "(RW)" );
      ctrl.STATE_REFILL_UPDATE:          vc_trace.append_str( trace_str, "(RU)" );
      ctrl.STATE_EVICT_PREPARE:          vc_trace.append_str( trace_str, "(EP)" );
      ctrl.STATE_EVICT_REQUEST:          vc_trace.append_str( trace_str, "(ER)" );
      ctrl.STATE_EVICT_WAIT:             vc_trace.append_str( trace_str, "(EW)" );
      ctrl.STATE_FAIL:                   vc_trace.append_str( trace_str, "(FL)" );
      default:                           vc_trace.append_str( trace_str, "(? )" );

    endcase

  end
  `VC_TRACE_END

endmodule

`endif
