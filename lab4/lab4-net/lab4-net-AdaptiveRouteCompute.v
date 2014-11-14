//========================================================================
// Greedy Route Computation
//========================================================================

`ifndef LAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V
`define LAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V

module lab4_net_AdaptiveRouteCompute
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter p_num_free_nbits = 3,
  parameter f                = 2,       // bits to represent 3 possible values of channel free entries          

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0]     dest,
  input  logic [f-1:0]                forw_free_one,
  input  logic [f-1:0]                forw_free_two,
  input  logic [f-1:0]                backw_free_one,
  input  logic [f-1:0]                backw_free_two,
  output logic [2:0]                  reqs
);

  logic [c_dest_nbits-1:0] 			  cur;
  assign cur = p_router_id;



endmodule

`endif  /* LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
