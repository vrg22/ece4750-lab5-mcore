//========================================================================
// Router Output Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_OUTPUT_CTRL_V
`define LAB4_NET_ROUTER_OUTPUT_CTRL_V

module lab4_net_RouterOutputCtrl
(
  input  logic       clk,
  input  logic       reset,

  input  logic [2:0] reqs,
  output logic [2:0] grants,

  output logic       out_val,
  input  logic       out_rdy,
  output logic [1:0] xbar_sel
);

  // add logic here

  assign grants = 0;
  assign out_val = 0;
  assign xbar_sel = 0;

endmodule

`endif /* LAB4_NET_ROUTER_OUTPUT_CTRL_V */
