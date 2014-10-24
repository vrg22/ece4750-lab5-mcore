//=========================================================================
// Baseline Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V

`include "vc-mem-msgs.v"


module lab3_mem_BlockingCacheBaseDpath
#(
  parameter size    = 256,            // Cache size in bytes

  parameter p_idx_shamt = 0,

  parameter p_opaque_nbits   = 8,

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache
  parameter idw     = $clog2(nblocks),// Short name for index width

  parameter o = p_opaque_nbits
)
(
  input  logic                                             clk,
  input  logic                                             reset,

  // Cache Request

  input  logic [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0]      cachereq_msg,

  // Cache Response

  output logic [`VC_MEM_RESP_MSG_NBITS(o,dbw)-1:0]         cacheresp_msg,

  // Memory Request

  output logic [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0]      memreq_msg,

  // Memory Response

  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg


  // control signals (ctrl->dpath)

  input logic         cachereq_en;
  input logic         memresp_en;
  input logic         refill_mux_sel;

  // status signals (dpath->ctrl)

  output logic [2:0]  cachereq_type,
  output logic [31:0] cachereq_addr,
  output logic        tag_match

);

  // Set cache response message to zeros

  assign cacheresp_msg = {`VC_MEM_RESP_MSG_NBITS(o,dbw){1'b0}};

  // Set memory request message to zeros

  assign memreq_msg    = {`VC_MEM_REQ_MSG_NBITS(o,abw,clw){1'b0}};


  //--------------------------------------------------------------------
  // Stage 0
  //--------------------------------------------------------------------


  logic [2:0]     cachereq_type_temp;
  logic [o-1:0]   cachereq_opaque;
  logic [abw-1:0] cachereq_addr_temp;
  logic [abw-1:0] cachereq_addr;
  logic [dbw-1:0] cachereq_data_temp;
  logic [dbw-1:0] cachereq_data;
  logic [clw-1:0] memresp_data_temp;
  logic [clw-1:0] memresp_data;


  // Unpack Cache Request Message

  vc_MemReqMsgUnpack#(o,abw,dbw) mem_req_msg_unpack
  (
    .msg    (cachereq_msg),
    .type_  (cachereq_type_temp),
    .opaque (cachereq_opaque),
    .addr   (cachereq_addr_temp),
    .len    (),
    .data   (imemresp_msg_data)
  );

  // Unpack Memory Response Message

  vc_MemRespMsgUnpack#(o,dbw) mem_resp_msg_unpack
  (
    .msg     (memresp_msg),
    .type_   (),
    .opaque  (),
    .len     (),
    .data    (memresp_data_temp)
  );


 vc_EnResetReg #(3) cachereq_type_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_type_temp),
    .q      (cachereq_type)
  );

  vc_EnResetReg #(abw) cachereq_addr_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_type_addr),
    .q      (cachereq_addr)
  );

  vc_EnResetReg #(o) cachereq_opaque_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_opaque),
    .q      ()
  );

  vc_EnResetReg #(dbw) cachereq_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_data_temp),
    .q      (cachereq_data)
  );

  vc_EnResetReg # (clw) memresp_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (memresp_data_temp),
    .q      (memresp_data)
  );


  // Write data 

  logic [127:0] replicate;

  assign repl_cachereq= {cachereq_data, cachereq_data, cachereq_data, cachereq_data};

  vc_Mux2 #(clw) refill_mux
  (
    .in0  (repl_cachereq),
    .in1  (memresp_data),
    .sel  (refill_mux_sel),
    .out  (write_data)
  );


  // retrieve idx and tag fields

  logic [idw]   idx;
  logic [24:0]  tag;

  assign idx= cachereq_addr[idw+4-1:4];
  assign tag= cachereq_addr[adw+idw+4-1:idw+4]; 









  //--------------------------------------------------------------------
  // Stage 1
  //--------------------------------------------------------------------





endmodule

`endif
