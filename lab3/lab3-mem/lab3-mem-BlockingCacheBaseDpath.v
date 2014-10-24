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

  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg,


  // control signals (ctrl->dpath)

  input logic         cachereq_en,
  input logic         memresp_en,
  input logic         refill_mux_sel,
  input logic         tag_array_wen,
  input logic         tag_array_ren,
  input logic         data_array_wen,
  input logic         data_array_ren,
  input logic [15:0]  data_array_wben,                  
  input logic         read_data_reg_en,
  input logic         read_tag_reg_en,
  input logic         memreq_tag_mux_sel,
  input logic [1:0]   read_byte_mux_sel,
  input logic [2:0]   cacheresp_type,
  input logic [2:0]   memreq_type,

  // status signals (dpath->ctrl)

  output logic [2:0]      cachereq_type,
  output logic [abw-1:0]  cachereq_addr,
  output logic            tag_match

);


  //--------------------------------------------------------------------
  // Stage 0
  //--------------------------------------------------------------------


  logic [2:0]     cachereq_type_temp;
  logic [o-1:0]   cachereq_opaque;
  logic [abw-1:0] cachereq_addr_temp;
  logic [abw-1:0] cachereq_addr_out;
  logic [dbw-1:0] cachereq_data_temp;
  logic [dbw-1:0] cachereq_data;
  logic [clw-1:0] memresp_data_temp;
  logic [clw-1:0] memresp_data;


  // Unpack Cache Request Message

  vc_MemReqMsgUnpack#(o,abw,dbw) memreq_msg_unpack
  (
    .msg    (cachereq_msg),
    .type_  (cachereq_type_temp),
    .opaque (cachereq_opaque),
    .addr   (cachereq_addr_temp),
    .len    (),
    .data   (cachereq_data_temp)
  );

  // Unpack Memory Response Message

  vc_MemRespMsgUnpack#(o,clw) memresp_msg_unpack
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
    .d      (cachereq_addr_temp),
    .q      (cachereq_addr_out)
  );

  assign cachereq_addr= cachereq_addr_out;

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

  vc_EnResetReg #(clw) memresp_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (memresp_data_temp),
    .q      (memresp_data)
  );


  // Write data 

  logic [clw-1:0] repl_cachereq;
  logic [clw-1:0] write_data;

  assign repl_cachereq= {cachereq_data, cachereq_data, cachereq_data, cachereq_data};

  vc_Mux2 #(clw) refill_mux
  (
    .in0  (repl_cachereq),
    .in1  (memresp_data),
    .sel  (refill_mux_sel),
    .out  (write_data)
  );


  // retrieve idx and tag fields

  logic [idw-1:0]       idx;
  logic [abw-1-idw-4:0] tag;

  assign idx= cachereq_addr_out[idw+4-1:4];
  assign tag= cachereq_addr_out[abw-1:idw+4]; 


  // SRAMs

  logic [abw-1-idw-4:0]   read_tag;
  logic [clw-1:0]         read_data;

  vc_CombinationalSRAM_1rw #(abw-idw-4,nblocks) tag_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (tag_array_ren),
    .read_addr      (idx),
    .read_data      (read_tag),
    .write_en       (tag_array_wen),
    .write_byte_en  (3'b111),
    .write_addr     (idx),
    .write_data     (tag)
  );

  vc_CombinationalSRAM_1rw #(clw,nblocks) data_array
  (
    .clk            (clk),
    .reset          (reset),
    .read_en        (data_array_ren),
    .read_addr      (idx),
    .read_data      (read_data),
    .write_en       (data_array_wen),
    .write_byte_en  (data_array_wben),
    .write_addr     (idx),
    .write_data     (write_data)
  );


  vc_EqComparator #(abw-idw-4) tag_comparator
  (
    .in0            (tag),
    .in1            (read_tag),
    .out            (tag_match)
  );



  //--------------------------------------------------------------------
  // Stage 1
  //--------------------------------------------------------------------

 
  logic [clw-1:0]       read_data_temp;
  logic [abw-1-idw-4:0] read_tag_out;  
  logic [abw-1-idw-4:0] tag_out;       
  logic [abw-1:0]       addr_out;  
  logic [dbw-1:0]       read_data_out;    


  vc_EnResetReg #(clw) read_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (read_data_reg_en),
    .d      (read_data),
    .q      (read_data_temp)
  );

  vc_EnResetReg #(abw-idw-4) read_tag_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (read_tag_reg_en),
    .d      (read_tag),
    .q      (read_tag_out)
  );

  vc_Mux2 #(abw-idw-4) memreq_tag_mux
  (
    .in0  (read_tag_out),
    .in1  (tag),
    .sel  (memreq_tag_mux_sel),
    .out  (tag_out)
  );

  assign addr_out= {tag_out,idx,4'b0};


  vc_Mux4 #(dbw) read_byte_mux
  (
    .in0  (read_data_temp[dbw-1:0]),
    .in1  (read_data_temp[2*dbw-1:dbw]),
    .in2  (read_data_temp[3*dbw-1:2*dbw]),
    .in3  (read_data_temp[4*dbw-1:3*dbw]),
    .sel  (read_byte_mux_sel),
    .out  (read_data_out)
  );


  // Pack Cache Response Message

  vc_MemRespMsgPack #(o,dbw) cacheresp_msg_pack
  (
    .type_    (cacheresp_type),
    .opaque   (8'b0),
    .len      (2'b0),
    .data     (read_data_out),
    .msg      (cacheresp_msg)
  );

  // Pack Memory Request Message

  vc_MemReqMsgPack #(o,abw,clw) memreq_msg_pack
  (
    .type_    (memreq_type),
    .opaque   (8'b0),
    .addr     (addr_out),
    .len      (4'b0),
    .data     (read_data_temp),
    .msg      (memreq_msg)
  );


endmodule

`endif
