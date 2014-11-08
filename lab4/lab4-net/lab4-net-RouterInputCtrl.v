//========================================================================
// Router Input Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_CTRL_V
`define LAB4_NET_ROUTER_INPUT_CTRL_V


module lab4_net_RouterInputCtrl
#(
  parameter p_router_id   = 0,
  parameter p_num_routers = 8,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  logic [c_dest_nbits-1:0] dest,

  input  logic                    in_val,
  output logic                    in_rdy,

  output logic [2:0]              reqs,
  input  logic [2:0]              grants
);




  // add logic here
  //compute requests based on algorithm, 
  //use dest, val rdy, grants to figure out whether or not to
  //set the rdy 

  assign in_rdy = 0;
  assign reqs = 0;





endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_CTRL_V */
