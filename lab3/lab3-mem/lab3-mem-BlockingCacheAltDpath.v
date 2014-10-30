//=========================================================================
// Alternative Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_DPATH_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_DPATH_V

`include "vc-mem-msgs.v"
`include "vc-srams.v"
`include "vc-arithmetic.v"
`include "lab3_mem_BlockingCacheAltWay.v"

module lab3_mem_BlockingCacheAltDpath
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

  parameter o       = p_opaque_nbits,
  parameter lww     = clw/dbw,         // Short name for words in line
  parameter odw     = $clog2(lww)     // Short name for offset width
)
(
  // Clock and reset signals
  input  logic                                             clk,
  input  logic                                             reset,

  // Left to right Datapath and Control Signals
  input  logic [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0]      cachereq_msg,
  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg,
  input  logic                                             memresp_en, 
  input  logic                                             cachereq_en, 
  output logic [2:0]                                       cachereq_type, 
  output logic [abw-1:0]                                   cachereq_addr,

  input  logic                                             write_data_mux_sel,

  input  logic                                             tag_array_ren, 
  input  logic                                             tag_array0_wen,
  input  logic                                             tag_array1_wen,
  input  logic                                             data_array_ren,
  input  logic                                             data_array0_wen,
  input  logic                                             data_array1_wen,
  input  logic [15:0]                                      data_array_wben,
  input  logic                                             read_data_reg_en,

  output logic                                             tag0_match,
  output logic                                             tag1_match,

  input  logic                                             evict_addr_reg_en,
  input  logic [2:0]                                       read_word_mux_sel, 
  input  logic                                             memreq_addr_mux_sel, 
  input  logic [2:0]                                       cacheresp_type,
  input  logic [2:0]                                       memreq_type, 


  output logic [`VC_MEM_RESP_MSG_NBITS(o,dbw)-1:0]         cacheresp_msg,
  output logic [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0]      memreq_msg
);

//-----------------------------------------------------------------------------
// Stage 0
//-----------------------------------------------------------------------------

  logic [2:0]     cachereq_type_in;
  logic [abw-1:0] cachereq_addr_in;
  logic [dbw-1:0] cachereq_data_reg_in;
   
  logic [7:0] opq;
  vc_MemReqMsgUnpack#(o,abw,dbw) memreq_msg_unpack
  (
    .msg      (cachereq_msg),
    .type_    (cachereq_type_in),
    .opaque   (opq),
    .addr     (cachereq_addr_in),
    .len      (),
    .data     (cachereq_data_reg_in)
  );

  logic [clw-1:0] memresp_data_in;
  vc_MemRespMsgUnpack#(o,clw) memresp_msg_unpack
  (
    .msg      (memresp_msg),
    .type_    (),
    .opaque   (),
    .len      (),
    .data     (memresp_data_in)
  );


  logic [7:0] pack_opq;
  vc_EnReg #(8) cachereq_opaque_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (cachereq_en),
    .d        (opq),
    .q        (pack_opq)
  );  

  vc_EnReg #(3) cachereq_type_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (cachereq_en),
    .d        (cachereq_type_in),
    .q        (cachereq_type)
  );
 
  vc_EnReg #(abw) cachereq_addr_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (cachereq_en),
    .d        (cachereq_addr_in),
    .q        (cachereq_addr)
  );

  logic [dbw-1:0] cachereq_data;
  vc_EnReg #(dbw) cachereq_data_reg 
  (
    .clk      (clk),
    .reset    (reset),
    .en       (cachereq_en),
    .d        (cachereq_data_reg_in),
    .q        (cachereq_data)
  );

  logic [clw-1:0] memresp_data;
  vc_EnReg #(clw) memresp_data_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (memresp_en),
    .d        (memresp_data_in),
    .q        (memresp_data)
  );

  logic [clw-1:0] repl_cachereq;
  logic [clw-1:0] wd;
  
  assign repl_cachereq= {cachereq_data, cachereq_data, cachereq_data, cachereq_data};
  
  vc_Mux2 #(clw) data_write_mux
  (
    .in0      (repl_cachereq),
    .in1      (memresp_data),
    .sel      (write_data_mux_sel),
    .out      (wd)
  );

  logic [abw-1:0] memreq_addr_way0;
  logic [clw-1:0] cacheresp_msg_data_way0;
  lab3_mem_BlockingCacheAltWay way0
  (
    .clk                    (clk),
    .reset                  (reset),
    .cachereq_addr          (cachereq_addr),
    .tag_array_ren          (tag_array_ren),
    .tag_array_wen          (tag_array0_wen),
    .data_array_ren         (data_array_ren),
    .data_array_wen         (data_array0_wen),
    .cache_line_write       (wd),
    .data_array_wben        (data_array_wben),
    .tag_match              (tag0_match),
    .memreq_addr_mux_sel    (memreq_addr_mux_sel),
    .evict_addr_reg_en      (evict_addr_reg_en),
    .read_word_mux_sel      (read_word_mux_sel),
    .memreq_addr            (memreq_addr_way0),
    .cacheresp_msg_data     (cacheresp_msg_data_way0)
  );

  logic [abw-1:0] memreq_addr_way1;
  logic [clw-1:0] cacheresp_msg_data_way1;
  lab3_mem_BlockingCacheAltWay way1
  (
    .clk                    (clk),
    .reset                  (reset),
    .cachereq_addr          (cachereq_addr),
    .tag_array_ren          (tag_array_ren),
    .tag_array_wen          (tag_array1_wen),
    .data_array_ren         (data_array_ren),
    .data_array_wen         (data_array1_wen),
    .cache_line_write       (wd),
    .data_array_wben        (data_array_wben),
    .tag_match              (tag0_match),
    .memreq_addr_mux_sel    (memreq_addr_mux_sel),
    .evict_addr_reg_en      (evict_addr_reg_en),
    .read_word_mux_sel      (read_word_mux_sel),
    .memreq_addr            (memreq_addr_way1),
    .cacheresp_msg_data     (cacheresp_msg_data_way1)
  );
  

  // Pack Cache Response Message

  vc_MemRespMsgPack #(o,dbw) cacheresp_msg_pack
  (
    .type_    (cacheresp_type),
    .opaque   (pack_opq),
    .len      (2'b0),
    .data     (cacheresp_msg_data),
    .msg      (cacheresp_msg)
  );

  // Pack Memory Request Message

  vc_MemReqMsgPack #(o,abw,clw) memreq_msg_pack
  (
    .type_    (memreq_type),
    .opaque   (8'b0),
    .addr     (memreq_addr),
    .len      (4'b0),
    .data     (valid_cache_data),
    .msg      (memreq_msg)
  );

endmodule

`endif
