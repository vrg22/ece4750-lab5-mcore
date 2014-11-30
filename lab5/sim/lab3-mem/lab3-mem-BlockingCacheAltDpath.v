//=========================================================================
// Alternative Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_DPATH_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_DPATH_V

`include "vc-mem-msgs.v"
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "vc-arithmetic.v"
`include "vc-muxes.v"
`include "vc-srams.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

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

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
//   input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  input  logic [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]         memresp_msg,
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  // control signals (ctrl->dpath)
  input  logic [1:0]                                       amo_sel,
  input  logic                                             cachereq_en,
  input  logic                                             memresp_en,
  input  logic                                             is_refill,
  input  logic                                             tag_array_0_wen,
  input  logic                                             tag_array_0_ren,
  input  logic                                             tag_array_1_wen,
  input  logic                                             tag_array_1_ren,
  input  logic                                             way_sel,
  input  logic                                             data_array_wen,
  input  logic                                             data_array_ren,
  // width of cacheline divided by number of bits per byte
  input  logic [clw/8-1:0]                                 data_array_wben,
  input  logic                                             read_data_reg_en,
  input  logic                                             read_tag_reg_en,
  input  logic [$clog2(clw/dbw)-1:0]                       read_byte_sel,
  input  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0]    memreq_type,
  input  logic [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0]    cacheresp_type,

  // status signals (dpath->ctrl)
  output logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0] cachereq_type,
  output logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] cachereq_addr,
  output logic                                             tag_match_0,
  output logic                                             tag_match_1
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
);

//+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++++
// 
//   // Set cache response message to zeros
// 
//   assign cacheresp_msg = {`VC_MEM_RESP_MSG_NBITS(o,dbw){1'b0}};
// 
//   // Set memory request message to zeros
// 
//   assign memreq_msg    = {`VC_MEM_REQ_MSG_NBITS(o,abw,clw){1'b0}};
// 
//+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  // Unpack cache request

  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0]   cachereq_addr_out;
  logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0]   cachereq_data_out;
  logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw)-1:0] cachereq_opaque_out;
  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0]   cachereq_type_out;
  logic [`VC_MEM_REQ_MSG_LEN_NBITS(o,abw,dbw)-1:0]    cachereq_len_out;

  vc_MemReqMsgUnpack#(o,abw,dbw) cachereq_msg_unpack
  (
    .msg    (cachereq_msg),

    .type_  (cachereq_type_out),
    .opaque (cachereq_opaque_out),
    .addr   (cachereq_addr_out),
    .len    (cachereq_len_out),
    .data   (cachereq_data_out)
  );

  // Unpack memory response

  logic [`VC_MEM_RESP_MSG_DATA_NBITS(o,clw)-1:0]      memresp_data_out;

  vc_MemRespMsgUnpack#(o,clw) memresp_msg_unpack
  (
    .msg    (memresp_msg),

    .opaque (),
    .type_  (),
    .len    (),
    .data   (memresp_data_out)
  );

  // Register the unpacked cachereq_msg

  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0]   cachereq_addr_reg_out;
  logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0]   cachereq_data_reg_out;
  logic [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0]   cachereq_type_reg_out;
  logic [`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw)-1:0] cachereq_opaque_reg_out;

  vc_EnResetReg #(`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw), 0) cachereq_type_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_type_out),
    .q      (cachereq_type_reg_out)
  );

  vc_EnResetReg #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw), 0) cachereq_addr_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_addr_out),
    .q      (cachereq_addr_reg_out)
  );

  vc_EnResetReg #(`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw), 0) cachereq_opaque_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_opaque_out),
    .q      (cachereq_opaque_reg_out)
  );

  vc_EnResetReg #(`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw), 0) cachereq_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (cachereq_en),
    .d      (cachereq_data_out),
    .q      (cachereq_data_reg_out)
  );

  assign cachereq_type = cachereq_type_reg_out;
  assign cachereq_addr = cachereq_addr_reg_out;

  // Register the unpacked data from memresp_msg

  logic [clw-1:0]                                   memresp_data_reg_out;

  vc_EnResetReg #(clw, 0) memresp_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (memresp_en),
    .d      (memresp_data_out),
    .q      (memresp_data_reg_out)
  );

  // Generate cachereq write data which will be the data field or some
  // calculation with the read data for amos

  logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0] cachereq_write_data;
  logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0] read_byte_sel_mux_out;

  vc_Mux4 #(dbw) amo_sel_mux
  (
    .in0  (cachereq_data_reg_out),
    .in1  (cachereq_data_reg_out + read_byte_sel_mux_out),
    .in2  (cachereq_data_reg_out & read_byte_sel_mux_out),
    .in3  (cachereq_data_reg_out | read_byte_sel_mux_out),
    .sel  (amo_sel),
    .out  (cachereq_write_data)
  );


  // Replicate cachereq_write_data

  logic [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*clw/dbw-1:0] cachereq_write_data_replicated;

  genvar i;
  generate
    for ( i = 0; i < clw/dbw; i = i + 1 ) begin
      assign cachereq_write_data_replicated[`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*(i+1)-1:`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*i] = cachereq_write_data;
    end
  endgenerate

  // Refill mux

  logic [`VC_MEM_RESP_MSG_DATA_NBITS(o,clw)-1:0] refill_mux_out;

  vc_Mux2 #(clw) refill_mux
  (
    .in0  (cachereq_write_data_replicated),
    .in1  (memresp_data_reg_out),
    .sel  (is_refill),
    .out  (refill_mux_out)
  );

  // Taking slices of the cache request address
  //     byte offset: 2 bits wide
  //     word offset: 2 bits wide
  //     index: $clog2(nblocks) - 1 bits wide
  //     nbits: width of tag = width of addr - $clog2(nblocks) - 4
  //     entries: 256*8/128 = 16
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0] cachereq_tag;
  // Index is 3 bits to account for the way number
  logic [2:0]                                         cachereq_idx;

  assign cachereq_tag = cachereq_addr_reg_out[`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:4];
  // -1 for way
  assign cachereq_idx = cachereq_addr_reg_out[4+p_idx_shamt +: 3];

  // Tag array
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] tag_array_0_read_out;

  vc_CombinationalSRAM_1rw #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw),nblocks/2) tag_array_0
  (
    .clk           (clk),
    .reset         (reset),
    .read_addr     (cachereq_idx),
    .read_data     (tag_array_0_read_out),
    .write_en      (tag_array_0_wen),
    .read_en       (tag_array_0_ren),
    .write_byte_en (4'b1111),
    .write_addr    (cachereq_idx),
    .write_data    ( { 4'h0, cachereq_tag } )
  );

  // Tag array 1
  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] tag_array_1_read_out;

  vc_CombinationalSRAM_1rw #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw),nblocks/2) tag_array_1
  (
    .clk           (clk),
    .reset         (reset),
    .read_addr     (cachereq_idx),
    .read_data     (tag_array_1_read_out),
    .write_en      (tag_array_1_wen),
    .read_en       (tag_array_1_ren),
    .write_byte_en (4'b1111),
    .write_addr    (cachereq_idx),
    .write_data    ( { 4'h0, cachereq_tag } )
  );

  logic [clw-1:0] data_array_read_out;

  // Data array
  vc_CombinationalSRAM_1rw #(clw, nblocks) data_array
  (
    .clk           (clk),
    .reset         (reset),
    // Whether way_sel is appended or prepended does not matter since
    // it's just a matter of how the cachelines are actually organized in
    // the data_array
    .read_addr     ( { cachereq_idx, way_sel } ),
    .read_data     (data_array_read_out),
    .write_en      (data_array_wen),
    .read_en       (data_array_ren),
    .write_byte_en (data_array_wben),
    .write_addr    ( { cachereq_idx, way_sel } ),
    .write_data    (refill_mux_out)
  );

  // Eq comparator to check for tag matching (tag_compare_0)
  vc_EqComparator #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) tag_compare_0
  (
    .in0 (cachereq_tag),
    .in1 (tag_array_0_read_out[27:0]),
    .out (tag_match_0)
  );

  // Eq comparator to check for tag matching (tag_compare_1)
  vc_EqComparator #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) tag_compare_1
  (
    .in0 (cachereq_tag),
    .in1 (tag_array_1_read_out[27:0]),
    .out (tag_match_1)
  );

  // Mux that selects between the ways for requesting from memory
  logic [27:0]    way_sel_mux_out;

  vc_Mux2 #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) way_sel_mux
  (
    .in0 (tag_array_0_read_out[27:0]),
    .in1 (tag_array_1_read_out[27:0]),
    .sel (way_sel),
    .out (way_sel_mux_out)
  );

  // Read data register

  logic [clw-1:0]   read_data_reg_out;

  vc_EnResetReg #(clw, 0) read_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (read_data_reg_en),
    .d      (data_array_read_out),
    .q      (read_data_reg_out)
  );

  // Read data register

  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0]   read_tag_reg_out;

  vc_EnResetReg #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4, 0) read_tag_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (read_tag_reg_en),
    .d      (way_sel_mux_out),
    .q      (read_tag_reg_out)
  );

  // Memreq Type Mux

  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0] memreq_type_mux_out;

  vc_Mux2 #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) memreq_type_mux
  (
    .in0  (cachereq_tag),
    .in1  (read_tag_reg_out),
    // TODO: change the following
    .sel  (memreq_type[0]),
    .out  (memreq_type_mux_out)
  );

  // Pack address for memory request

  logic [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,clw)-1:0] memreq_addr;
  assign memreq_addr = { memreq_type_mux_out, 4'b0000 };

  // Select byte for cache response

  vc_Mux4 #(dbw) read_byte_sel_mux
  (
    .in0  (read_data_reg_out[dbw-1:0]),
    .in1  (read_data_reg_out[2*dbw-1:1*dbw]),
    .in2  (read_data_reg_out[3*dbw-1:2*dbw]),
    .in3  (read_data_reg_out[4*dbw-1:3*dbw]),
    .sel  (read_byte_sel),
    .out  (read_byte_sel_mux_out)
  );

  // Pack cache response

  vc_MemRespMsgPack#(o,dbw) cacheresp_msg_pack
  (
    .type_  (cacheresp_type),
    .opaque (cachereq_opaque_reg_out),
    .len    (2'b0),
    .data   (read_byte_sel_mux_out),
    .msg    (cacheresp_msg)
  );

  // Pack cache response
  vc_MemReqMsgPack#(o,abw,clw) memreq_msg_pack
  (
    .type_  (memreq_type),
    .opaque (8'b0),
    .addr   (memreq_addr),
    .len    (4'b0),
    .data   (read_data_reg_out),
    .msg    (memreq_msg)
  );
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif
