
`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_WAY_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_WAY_V

`include "vc-mem-msgs.v"
`include "vc-srams.v"
`include "vc-arithmetic.v"
module lab3_mem_BlockingCacheAltWay
#(
  parameter size        = 128, // Way size in bytes
  parameter p_idx_shamt = 0,

  parameter dbw         = 32,
  parameter abw         = 32,
  parameter clw         = 128,
  parameter nblocks     = size*8/clw,
  parameter idw         = $clog2(nblocks),

  parameter lww         = clw/dbw,
  parameter odw         = $clog2(lww)
)
(
  input  logic              clk,
  input  logic              reset,
  input  logic [abw-1:0]    cachereq_addr,
  input  logic              tag_array_ren, 
  input  logic              tag_array_wen,
  input  logic              data_array_ren,
  input  logic              data_array_wen,
  input  logic [clw-1:0]    cache_line_write,
  input  logic [15:0]       data_array_wben,
  input  logic              read_data_reg_en,

  output logic              tag_match,

  input  logic              memreq_addr_mux_sel,
  input  logic              evict_addr_reg_en,
  input  logic [2:0]        read_word_mux_sel,  

  output logic [abw-1:0]    memreq_addr,
  output logic [dbw-1:0]    cacheresp_msg_data,
  output logic [clw-1:0]    valid_cache_data    
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
    .write_byte_en  (4'b1111),
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
    .write_data     (cache_line_write)
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


  logic [abw-1:0] evict_addr;
  vc_EnResetReg #(abw) evict_tag_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (evict_addr_reg_en),
    .d      (mk_addr),
    .q      (evict_addr)
  );

  logic [abw-1:0] line_alinged_addr; // BELOW LINE HARDCODED, FIX
  assign line_alinged_addr = { cachereq_addr[abw-1:2+idw+odw] , 6'b0 };
  vc_Mux2 #(abw) memreq_addr_mux
  (
    .in0      (evict_addr),
    .in1      (line_alinged_addr),
    .sel      (memreq_addr_mux_sel),
    .out      (memreq_addr)
  );

  vc_EnReg #(clw) read_data_reg
  (
    .clk      (clk),
    .reset    (reset),
    .en       (read_data_reg_en),
    .d        (cache_data),
    .q        (valid_cache_data)
  );

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
  
endmodule

`endif
