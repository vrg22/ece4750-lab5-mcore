//========================================================================
// Router Adaptive Input Terminal Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V
`define LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V

`include "lab4-net-AdaptiveRouteCompute.v"


module lab4_net_RouterAdaptiveInputTerminalCtrl
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter f                = 2,       // bits to represent 3 possible values of channel free entries

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0]     dest,

  input  logic                        in_val,     
  output logic                        in_rdy,

  input  logic [f-1:0]                forw_free_one,
  input  logic [f-1:0]                forw_free_two,
  input  logic [f-1:0]                backw_free_one,
  input  logic [f-1:0]                backw_free_two,

  output logic [2:0]                  reqs,
  input  logic [2:0]                  grants
);

  logic [2:0]              reqs_temp;

  //Adaptive, Non-deterministic Routing Algorithm
  lab4_net_AdaptiveRouteCompute#(p_router_id, p_num_routers, f) adaptive_algorithm
  (
    .dest           (dest),
    .forw_free_one  (forw_free_one),
    .forw_free_two  (forw_free_two),
    .backw_free_one (backw_free_one),
    .backw_free_two (backw_free_two),
    .reqs           (reqs_temp)
  );


  always @(*) begin
    if ((reqs_temp == 3'b001) || (reqs_temp == 3'b100) || (reqs_temp == 3'b010))  
      reqs = (in_val) ? reqs_temp : 3'b000;   
    else 
      reqs = 3'b000;
  end


  //If what we are requesting is what is being granted, ready to dequeue
  // assign in_rdy = (grants == reqs);
  assign in_rdy = (grants != 3'b000) ? ((grants & reqs) == reqs) : 0;



endmodule

`endif  /* LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
