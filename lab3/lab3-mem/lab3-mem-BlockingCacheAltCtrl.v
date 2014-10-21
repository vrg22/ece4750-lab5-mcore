//=========================================================================
// Alternative Blocking Cache Control
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_CTRL_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_CTRL_V

`include "vc-mem-msgs.v"
`include "vc-assert.v"

module lab3_mem_BlockingCacheAltCtrl
#(
  parameter size    = 256,            // Cache size in bytes

  parameter p_idx_shamt = 0,

  parameter p_opaque_nbits  = 8,

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache

  parameter o = p_opaque_nbits
)
(
  input  logic                                            clk,
  input  logic                                            reset,

  // Cache Request

  input  logic                                            cachereq_val,
  output logic                                            cachereq_rdy,

  // Cache Response

  output logic                                            cacheresp_val,
  input  logic                                            cacheresp_rdy,

  // Memory Request

  output logic                                            memreq_val,
  input  logic                                            memreq_rdy,

  // Memory Response

  input  logic                                            memresp_val,
  output logic                                            memresp_rdy
 );

  // Drop incoming requests

  assign cachereq_rdy = 1'b1;

  // Always send out incorrect data

  assign cacheresp_val = 1'b1;

  // Do nothing for memory req/resp ports

  assign memreq_val  = 1'b0;
  assign memresp_rdy = 1'b0;

endmodule

`endif
