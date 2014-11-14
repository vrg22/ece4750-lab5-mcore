//========================================================================
// lab4-net-CongestionModule
//========================================================================

`ifndef LAB4_NET_CONGESTION_MODULE_V
`define LAB4_NET_CONGESTION_MODULE_V

`include "vc-regs.v"


module lab4_net_CongestionModule
#(
  parameter f = 2                  // bits to represent 3 possible values of channel free entries
)
(
  input   logic                       clk,
  input   logic                       reset,
  input   logic [f-1:0]               free_one_in,
  input   logic [f-1:0]               free_two_in,
  input   logic [f-1:0]               next_one_out,
  output  logic [f-1:0]               free_one_out,
  output  logic [f-1:0]               free_two_out
);


logic [f-1:0] free_one_out_temp;
logic [f-1:0] free_two_out_temp;

module vc_ResetReg#(f, 0) one_hop_reg
(
  .clk      (clk),                    // Clock input
  .reset    (reset),                  // Sync reset input
  .q        (free_one_out_temp),      // Data output
  .d        (free_one_in)             // Data input
);

module vc_ResetReg#(f, 0) two_hop_reg
(
  .clk      (clk),                    // Clock input
  .reset    (reset),                  // Sync reset input
  .q        (free_two_out_temp),      // Data output
  .d        (free_two_in)             // Data input
);


assign free_one_out = next_one_out;           // msg from next channel queue -> one hop msg
assign free_two_out = free_one_out_temp;      // one hop msg -> two hop msg



endmodule
`endif /* LAB4_NET_CONGESTION_MODULE_V */
