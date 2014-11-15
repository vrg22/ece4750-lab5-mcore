//========================================================================
// Router Input Terminal Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V
`define LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "lab4-net-GreedyRouteCompute.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

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

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   // add logic here
// 
//   assign in_rdy = 0;
//   assign reqs = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  logic [1:0] route;

  //----------------------------------------------------------------------
  // Greedy Route Compute
  //----------------------------------------------------------------------

  lab4_net_GreedyRouteCompute
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers)
  )
  route_compute
  (
    .dest           (dest),
    .route          (route)
  );

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // rdy is just a reductive OR of the AND of reqs and grants

  assign in_rdy = | (reqs & grants);

  always @(*) begin
    if (in_val) begin

      case (route)
        // the following implements bubble flow control:
        `ROUTE_PREV:  reqs = (num_free_east > 1) ? 3'b001 : 3'b000;
        `ROUTE_TERM:  reqs = 3'b010;
        `ROUTE_NEXT:  reqs = (num_free_west > 1) ? 3'b100 : 3'b000;

        // the following doesn't implement bubble flow control:
        // `ROUTE_PREV:  reqs = 3'b001;
        // `ROUTE_TERM:  reqs = 3'b010;
        // `ROUTE_NEXT:  reqs = 3'b100;
      endcase

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
