//========================================================================
// Router Input Terminal Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V
`define LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V

module lab4_net_RouterInputTerminalCtrl
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter p_num_free_nbits = 2,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  logic [c_dest_nbits-1:0]     dest,

  input  logic                        in_val,
  output logic                        in_rdy,

  input  logic [p_num_free_nbits-1:0] num_free_west,
  input  logic [p_num_free_nbits-1:0] num_free_east,

  output logic [2:0]                  reqs,
  input  logic [2:0]                  grants
);

  // add logic here

  assign in_rdy = 0;
  assign reqs = 0;

endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
