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


//Arbiter to arbitrate access to resources
  vc_RoundRobinArb #(3) RR_arbiter
  (
    .clk       (clk),
    .reset     (reset),

    .reqs      (reqs),    // 1 = making a req, 0 = no req
    .grants    (grants)   // (one-hot) 1 is req won grant
  );



  // Q: Why didn't the below work when clocked?

  // always @(posedge clk) begin
    assign xbar_sel = (grants == 3'b001) ? 2'b00 :
                    (grants == 3'b010) ? 2'b01 :
                    (grants == 3'b100) ? 2'b10 :
                    2'b11;  //CHECK!

    assign out_val = (xbar_sel != 2'b11) && (reqs != 3'b000); //HOW TO DETERMINE??
  // end

endmodule

`endif /* LAB4_NET_ROUTER_OUTPUT_CTRL_V */
