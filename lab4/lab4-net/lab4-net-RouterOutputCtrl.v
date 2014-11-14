//========================================================================
// Router Output Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_OUTPUT_CTRL_V
`define LAB4_NET_ROUTER_OUTPUT_CTRL_V

`include "vc-arbiters.v"


module lab4_net_RouterOutputCtrl
(
  input  logic       clk,
  input  logic       reset,

  input  logic [2:0] reqs,
  output logic [2:0] grants,

  output logic       out_val,
  input  logic       out_rdy,       //How to use?
  output logic [1:0] xbar_sel
);

 logic [2:0] grants_temp;

  //Arbiter to arbitrate access to resources
  vc_RoundRobinArb #(3) RR_arbiter
  (
    .clk       (clk),
    .reset     (reset),

    .reqs      (reqs),              // 1 = making a req, 0 = no req
    .grants    (grants_temp)        // (one-hot) 1 is req won grant
  );

  assign xbar_sel = (grants_temp == 3'b001) ? 2'b00 :       // west
                    (grants_temp == 3'b010) ? 2'b01 :       // east
                    (grants_temp == 3'b100) ? 2'b10 :       // self
                    2'b11;  

  assign grants = out_rdy ? grants_temp : 3'b000;           // ensure packet is not dequeued unless out_rdy is high

  assign out_val = (grants != 3'b000) && (reqs != 3'b000);


endmodule

`endif /* LAB4_NET_ROUTER_OUTPUT_CTRL_V */
