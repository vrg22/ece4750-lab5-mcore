//========================================================================
// Router Input Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_CTRL_V
`define LAB4_NET_ROUTER_INPUT_CTRL_V


module lab4_net_RouterInputCtrl
#(
  parameter p_router_id   = 0,
  parameter p_num_routers = 8,

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  // indicates the reqs signal to pass through a message
  parameter p_default_reqs = 3'b001,

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

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

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   // add logic here
// 
//   assign in_rdy = 0;
//   assign reqs = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // rdy is just a reductive OR of the AND of reqs and grants

  assign in_rdy = | (reqs & grants);

  always @(*) begin
    if (in_val) begin

      // if the packet is for this port, redirect it to the terminal
      if ( dest == p_router_id )
        reqs = 3'b010;

      // otherwise, we just pass through it
      else
        reqs = p_default_reqs;

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_CTRL_V */
