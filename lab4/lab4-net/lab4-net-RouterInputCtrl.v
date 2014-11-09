//========================================================================
// Router Input Ctrl
//========================================================================

`ifndef LAB4_NET_ROUTER_INPUT_CTRL_V
`define LAB4_NET_ROUTER_INPUT_CTRL_V


module lab4_net_RouterInputCtrl
#(
  parameter p_router_id   = 0,
  parameter p_num_routers = 8,

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0] dest,

  input  logic                    in_val,     //How do we use in_val?
  output logic                    in_rdy,

  output logic [2:0]              reqs,
  input  logic [2:0]              grants
);

  // Propagate in current direction or until reaches destination
  assign reqs = (!in_val) ? 3'b000 :            /*Invalid to send now*/
                (dest > p_router_id) ? 3'b001 : /*East*/
                (dest < p_router_id) ? 3'b100 : /*West*/
                3'b010;   /*Reached Destination*/

  //If what we are requesting is what is being granted, ready to dequeue
  // assign in_rdy = (grants == reqs) && in_val;
  assign in_rdy = (grants == reqs);      //WHAT IS PURPOSE OF IN_VAL as an INPUT to this module?

endmodule

`endif  /* LAB4_NET_ROUTER_INPUT_CTRL_V */
