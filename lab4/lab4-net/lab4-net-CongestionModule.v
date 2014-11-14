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
  input   logic [f-1:0]               free_one_in,          // prev one hop congestion info from previous congestion module
  input   logic [f-1:0]               free_two_in,          // prev two hop congestion info from previous congestion module
  input   logic [f-1:0]               next_one_channel,     // next one hop congestion info from next channel queue
  output  logic [f-1:0]               free_one_router,      // prev one hop congestion info to router
  output  logic [f-1:0]               free_two_router,      // prev two hop congestion info to router
  output  logic [f-1:0]               free_one_out,         // next one hop congestion info to next congestion module
  output  logic [f-1:0]               free_two_out          // next two hop congestion info to next congestion module
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

assign free_one_router = free_one_out_temp;   // one hop msg -> router
assign free_two_router = free_two_out_temp;   // two hop msg -> router
assign free_one_out    = next_one_channel;    // msg from next channel queue -> one hop msg
assign free_two_out    = free_one_out_temp;   // one hop msg -> two hop msg



endmodule
`endif /* LAB4_NET_CONGESTION_MODULE_V */
