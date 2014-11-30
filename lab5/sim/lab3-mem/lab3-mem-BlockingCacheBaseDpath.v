//=========================================================================
// Baseline Blocking Cache Datapath
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V
`define LAB3_MEM_BLOCKING_CACHE_BASE_DPATH_V

`include "vc-mem-msgs.v"
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "vc-arithmetic.v"
`include "vc-muxes.v"
`include "vc-srams.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

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
  input  logic                                             tag_array_wen,
  input  logic                                             tag_array_ren,
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
  output logic                                             tag_match
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

  // For the tag we subtract
  //  - 2 bits for the byte offset within a word
  //  - 2 bits for the word offset within a line
  //  - 4 bits for the index

  localparam c_addr_nbits = `VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw);
  localparam c_idx_nbits  = $clog2(nblocks);
  localparam c_off_nbits  = $clog2(clw/8);
  localparam c_tag_nbits  = c_addr_nbits - c_idx_nbits - c_off_nbits;

  // Taking slices of the cache request address
  //     byte offset: 2 bits wide
  //     word offset: 2 bits wide
  //     index: $clog2(nblocks) bits wide
  //     nbits: width of tag = width of addr - $clog2(nblocks) - 4
  //     entries: 256*8/128 = 16

  logic [c_tag_nbits-1:0] cachereq_tag;
  logic [c_idx_nbits-1:0] cachereq_idx;

  assign cachereq_tag = cachereq_addr_reg_out[c_addr_nbits-1:c_idx_nbits+c_off_nbits];
  assign cachereq_idx = cachereq_addr_reg_out[(c_idx_nbits+c_off_nbits)-1:c_off_nbits];

  // Tag array
  logic [c_tag_nbits-1:0] tag_array_read_out;

  // We only want to store the tag, not all 32b of the address -cbatten
  vc_CombinationalSRAM_1rw
  #(
    .p_data_nbits  (c_tag_nbits),
    .p_num_entries (nblocks)
  )
  tag_array
  (
    .clk           (clk),
    .reset         (reset),
    .read_addr     (cachereq_idx),
    .read_data     (tag_array_read_out),
    .write_en      (tag_array_wen),
    .read_en       (tag_array_ren),
    .write_byte_en (3'b111),
    .write_addr    (cachereq_idx),
    .write_data    (cachereq_tag)
  );

  logic [clw-1:0] data_array_read_out;

  // Data array
  vc_CombinationalSRAM_1rw #(clw, nblocks) data_array
  (
    .clk           (clk),
    .reset         (reset),
    .read_addr     (cachereq_idx),
    .read_data     (data_array_read_out),
    .write_en      (data_array_wen),
    .read_en       (data_array_ren),
    .write_byte_en (data_array_wben),
    .write_addr    (cachereq_idx),
    .write_data    (refill_mux_out)
  );

  // Eq comparator to check for tag matching

  vc_EqComparator#(c_tag_nbits) tag_compare
  (
    .in0 (cachereq_tag),
    .in1 (tag_array_read_out),
    .out (tag_match)
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

  // mk addr for eviction

  logic [c_addr_nbits-1:0] addr_evict;
  assign addr_evict = { tag_array_read_out, cachereq_idx, {c_off_nbits{1'b0}} };

  // Read tag register

  logic [c_addr_nbits-1:0] addr_evict_reg_out;

  vc_EnResetReg#(c_addr_nbits,0) addr_evict_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (read_tag_reg_en),
    .d      (addr_evict),
    .q      (addr_evict_reg_out)
  );

  // mk addr for refill

  logic [c_addr_nbits-1:0] addr_refill;
  assign addr_refill = { cachereq_tag, cachereq_idx, {c_off_nbits{1'b0}} };

  // Memreq Type Mux

  logic [c_addr_nbits-1:0] memreq_addr;

  vc_Mux2#(c_addr_nbits) tag_mux
  (
    .in0  (addr_refill),
    .in1  (addr_evict_reg_out),
    // TODO: change the following
    .sel  (memreq_type[0]),
    .out  (memreq_addr)
  );

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
