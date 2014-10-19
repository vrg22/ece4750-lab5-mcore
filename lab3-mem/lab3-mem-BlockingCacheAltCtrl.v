//=========================================================================
// Alt Cache Control
//=========================================================================

`ifndef LAB3_MEM_BLOCKING_CACHE_ALT_CTRL_V
`define LAB3_MEM_BLOCKING_CACHE_ALT_CTRL_V

`include "vc-mem-msgs.v"

module lab3_mem_BlockingCacheAltCtrl
#(
  parameter size    = 256,            // Cache size in bytes

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw      // Number of blocks in the cache
)
(
  input  logic                                  clk,
  input  logic                                  reset,

  // Cache Request

  input  logic                                  cachereq_val,
  output logic                                  cachereq_rdy,

  // Cache Response

  output logic                                  cacheresp_val,
  input  logic                                  cacheresp_rdy,

  // Memory Request

  output logic                                  memreq_val,
  input  logic                                  memreq_rdy,

  // Memory Response

  input  logic                                  memresp_val,
  output logic                                  memresp_rdy
);

  // pass through the request and response signals in the null cache

  assign memreq_val    = cachereq_val;
  assign cachereq_rdy  = memreq_rdy;

  assign cacheresp_val = memresp_val;
  assign memresp_rdy   = cacheresp_rdy;

endmodule

`endif
