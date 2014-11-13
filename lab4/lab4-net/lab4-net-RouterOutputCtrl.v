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

    .reqs      (reqs),          // 1 = making a req, 0 = no req
    .grants    (grants)         // (one-hot) 1 is req won grant
  );


  assign xbar_sel = (grants == 3'b001 && out_rdy) ? 2'b00 :
                    (grants == 3'b010 && out_rdy) ? 2'b01 :
                    (grants == 3'b100 && out_rdy) ? 2'b10 :
                    2'b11;  //CHECK!

  assign out_val = (grants != 3'b000) && (reqs != 3'b000);
    // assign out_val = (xbar_sel != 2'b11) && (reqs != 3'b000); //HOW TO DETERMINE??
                     // && (out_rdy);
  // end


  // //Wires
  // logic  [1:0] xbar_sel_next;
  // logic        out_val_next;

  // //Arbiter to arbitrate access to resources
  // vc_RoundRobinArb #(3) RR_arbiter
  // (
  //   .clk       (clk),
  //   .reset     (reset),

  //   .reqs      (reqs),    // 1 = making a req, 0 = no req
  //   .grants    (grants)   // (one-hot) 1 is req won grant
  // );

  // //Combinational Logic
  // always @(*) begin
  //   xbar_sel_next = (grants == 3'b001) ? 2'b00 :
  //                   (grants == 3'b010) ? 2'b01 :
  //                   (grants == 3'b100) ? 2'b10 :
  //                   2'b11;

  //   out_val_next = (grants != 3'b000) && (reqs != 3'b000);
  // end

  // //Sequential stuff -> All signals should be clock aligned?
  // always @(posedge clk) begin
  //   xbar_sel <= xbar_sel_next;
  //   out_val <= out_val_next;
  // end

endmodule

`endif /* LAB4_NET_ROUTER_OUTPUT_CTRL_V */
