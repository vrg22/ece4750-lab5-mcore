//========================================================================
// Router Adaptive Input Terminal Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V
`define LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V

`include "lab4-net-AdaptiveRouteCompute.v"

module lab4_net_RouterAdaptiveInputTerminalCtrl
#(
  parameter p_router_id           = 0,
  parameter p_num_routers         = 8,
  parameter p_num_free_nbits      = 2,
  parameter p_num_free_chan_nbits = 2,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  logic  [c_dest_nbits-1:0]         dest,

  input  logic                             in_val,
  output logic                             in_rdy,

  input  logic [p_num_free_nbits-1:0]      num_free0,
  input  logic [p_num_free_nbits-1:0]      num_free2,

  input  logic [p_num_free_chan_nbits-1:0] num_free_chan0,
  input  logic [p_num_free_chan_nbits-1:0] num_free_chan2,

  output logic [2:0]                       reqs,
  input  logic [2:0]                       grants
);

  logic [1:0] route;

  //----------------------------------------------------------------------
  // Adaptive Route Compute
  //----------------------------------------------------------------------

  lab4_net_AdaptiveRouteCompute
  #(
    .p_router_id      (p_router_id),
    .p_num_routers    (p_num_routers),
    .p_num_free_nbits (p_num_free_chan_nbits)
  )
  route_compute
  (
    .dest           (dest),

    .num_free_chan0 (num_free_chan0),
    .num_free_chan2 (num_free_chan2),

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
        `ROUTE_PREV:  reqs = (num_free2 > 1) ? 3'b001 : 3'b000;
        `ROUTE_TERM:  reqs = 3'b010;
        `ROUTE_NEXT:  reqs = (num_free0 > 1) ? 3'b100 : 3'b000;
      endcase

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

endmodule

`endif  /* LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
