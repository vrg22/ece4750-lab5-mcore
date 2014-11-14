//========================================================================
// lab4-net-CongestionModule
//========================================================================

`ifndef LAB4_NET_CONGESTION_MODULE_V
`define LAB4_NET_CONGESTION_MODULE_V


module lab4_net_CongestionModule
#(
  parameter p_payload_nbits  = 32,
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,

  // Shorter names, not to be set from outside the module
  parameter p = p_payload_nbits,
  parameter o = p_opaque_nbits,
  parameter s = p_srcdest_nbits,

  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s)

  parameter f = 2                  // bits to represent 3 possible values of channel free entries
)
(
  
  output  logic [f-1:0]               forw_free_one,
  output  logic [f-1:0]               forw_free_two,
  output  logic [f-1:0]               backw_free_one,
  output  logic [f-1:0]               backw_free_two
);

// ADD RESET REGS


endmodule
`endif /* LAB4_NET_CONGESTION_MODULE_V */
