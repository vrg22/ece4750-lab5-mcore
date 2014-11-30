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
  parameter p_num_free_nbits = 3,       // 3 bits to represent 5 possible values in a 4-element queue (0,1,2,3,4)

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0]     dest,

  input  logic                        in_val,     
  output logic                        in_rdy,

  input  logic [p_num_free_nbits-1:0] num_free_west,
  input  logic [p_num_free_nbits-1:0] num_free_east,

  output logic [2:0]              reqs,
  input  logic [2:0]              grants
);

  logic [2:0]              reqs_temp;

  //Greedy, Deterministic Routing Algorithm
  lab4_net_GreedyRouteCompute#(p_router_id, p_num_routers) greedy_algorithm
  (
    .dest           (dest),
    // .in_val   (in_val),
    // .in_rdy   (in_rdy),
    .reqs           (reqs_temp)
    // .grants   (grants)
  );

  // Check for bubbles
  logic wb;             // west bubble     
  logic eb;             // east bubble
  assign eb = num_free_east >= 3'h1;
  assign wb = num_free_west >= 3'h1;


  always @(*) begin
    if (((reqs_temp == 3'b001) && eb) || ((reqs_temp == 3'b100) && wb) || (reqs_temp == 3'b010))  
      reqs = (in_val) ? reqs_temp : 3'b000;   
    else 
      reqs = 3'b000;
  end
  

  //If what we are requesting is what is being granted, ready to dequeue
  // assign in_rdy = (grants == reqs);
  assign in_rdy = (grants != 3'b000) ? ((grants & reqs) == reqs) : 0;


endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
