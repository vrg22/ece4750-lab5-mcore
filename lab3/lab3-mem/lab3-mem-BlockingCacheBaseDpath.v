//=========================================================================
// Baseline Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V

`include "vc-mem-msgs.v"
`include "vc-srams.v"
`include "vc-arithmetic.v"

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

  parameter o       = p_opaque_nbits,
  parameter lww     = clw/dbw,         // Short name for words in line
  parameter odw     = $clog2(lww)     // Short name for offset width
)
(
  // Clock and reset signals
  input  logic                                             clk,
  input  logic                                             reset,

  // Top half of datapath control signals
  input  logic [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0]      cachereq_msg, 
  input  logic                                             cachereq_en, 

  output logic [2:0]                                       cachereq_type, 
  output logic [abw-1:0]                                   cachereq_addr,

  input  logic                                             write_data_mux_sel,
  input  logic                                             tag_array_ren, 
  input  logic                                             tag_array_wen, 
  
  output logic                                             tag_match,
  input  logic                                             evict_addr_reg_en,
  input  logic                                             memreq_addr_mux_sel, 
  input  logic [2:0]                                       cacheresp_type,
  
  //Bottom half of datapath control signals  

  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg,
  input  logic                                             memresp_en,
  input  logic                                             data_array_ren,
  input  logic                                             data_array_wen,
  input  logic [15:0]                                      data_array_wben,
  input  logic                                             read_data_reg_en,
  input  logic [2:0]                                       read_word_mux_sel,
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
  
  vc_Mux2 #(clw) refill_mux
  (
    .in0      (repl_cachereq),
    .in1      (memresp_data),
    .sel      (write_data_mux_sel),
    .out      (wd)
  );
  
  logic [idw-1:0]             idx;
  logic [abw-1-(idw+odw+2):0] curr_tag;
      
  assign idx = cachereq_addr[idw+4-1:4];
  assign curr_tag = cachereq_addr[abw-1:idw+4];  
  
  // SRAMs

  logic [abw-1-(idw+odw+2):0]   read_tag;
  vc_CombinationalSRAM_1rw #(abw-(idw+odw+2),nblocks) tag_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (tag_array_ren),
    .read_addr      (idx),
    .read_data      (read_tag),
    .write_en       (tag_array_wen),
    .write_byte_en  (3'b111),
    .write_addr     (idx),
    .write_data     (curr_tag)
  );

  logic [clw-1:0]             cache_data;
  vc_CombinationalSRAM_1rw #(clw,nblocks) data_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (data_array_ren),
    .read_addr      (idx),
    .read_data      (cache_data),
    .write_en       (data_array_wen),
    .write_byte_en  (data_array_wben),
    .write_addr     (idx),
    .write_data     (wd)
  );

  vc_EqComparator #(abw-(idw+odw+2)) tag_comparator
  (
    .in0            (curr_tag),
    .in1            (read_tag),
    .out            (tag_match)
  );

  logic [abw-1:0] mk_addr;

  // 2 bits zero for offset alignment
  // 2 bits zero for byte alignment
  assign  mk_addr = {read_tag, idx, 4'b0};

//-----------------------------------------------------------------------------
// Stage 1
//-----------------------------------------------------------------------------

  logic [abw-1:0] evict_addr;
  vc_EnResetReg #(abw) evict_tag_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (evict_addr_reg_en),
    .d      (mk_addr),
    .q      (evict_addr)
  );

  logic [abw-1:0] memreq_addr;
  logic [abw-1:0] aligned_addr;
  assign aligned_addr = cachereq_addr & 32'hfffffff0;
  vc_Mux2 #(abw) memreq_addr_mux
  (
    .in0      (evict_addr),
    .in1      (aligned_addr),
    .sel      (memreq_addr_mux_sel),
    .out      (memreq_addr)
  );

  logic [clw-1:0] valid_cache_data;
  vc_EnReg #(clw) read_data_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (read_data_reg_en),
    .d        (cache_data),
    .q        (valid_cache_data)
  );

  logic [dbw-1:0] cacheresp_msg_data;
  vc_Mux5 #(dbw) read_word_mux
  (
    .in0      (valid_cache_data[dbw-1:0]),
    .in1      (valid_cache_data[2*dbw-1:dbw]),
    .in2      (valid_cache_data[3*dbw-1:2*dbw]),
    .in3      (valid_cache_data[4*dbw-1:3*dbw]),
    .in4      (32'b0),
    .sel      (read_word_mux_sel),
    .out      (cacheresp_msg_data)
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
