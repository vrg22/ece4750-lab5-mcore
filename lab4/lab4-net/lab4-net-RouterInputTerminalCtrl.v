//========================================================================
// Router Input Terminal Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V
`define LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V

`include "lab4-net-GreedyRouteCompute.v"


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

  input  logic                        in_val,     //Why does val come INTO the thing responsible for calculating rdy???
  output logic                        in_rdy,

  input  logic [p_num_free_nbits-1:0] num_free_west,
  input  logic [p_num_free_nbits-1:0] num_free_east,

  output logic [2:0]              reqs,
  input  logic [2:0]              grants
);

  // assign in_rdy = 0;
  // assign reqs = 0;

  //Greedy, Deterministic Routing Algorithm
  lab4_net_GreedyRouteCompute#(p_router_id, p_num_routers) greedy_algorithm
  (
    .dest     (dest),
    // .in_val   (in_val),
    // .in_rdy   (in_rdy),
    // .grants   (grants),
    .reqs     (reqs)
  );
  // assign reqs = (in_val) ? reqs : 3'b000;     //CORRECT?

  //If what we are requesting is what is being granted, ready to dequeue
  // assign in_rdy = (grants == reqs);
  assign in_rdy = ((grants & reqs) == reqs);      //WHAT IS PURPOSE OF IN_VAL as an INPUT to this module?

endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
