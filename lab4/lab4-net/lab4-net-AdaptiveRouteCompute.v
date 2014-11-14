//========================================================================
// Greedy Route Computation
//========================================================================

`ifndef LAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V
`define LAB4_NET_ADAPTIVE_ROUTE_COMPUTE_V

module lab4_net_AdaptiveRouteCompute
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter p_num_free_nbits = 3,
  parameter f                = 2,       // bits to represent 3 possible values of channel free entries          

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0]     dest,
  input  logic [f-1:0]                forw_free_one,
  input  logic [f-1:0]                forw_free_two,
  input  logic [f-1:0]                backw_free_one,
  input  logic [f-1:0]                backw_free_two,
  output logic [2:0]                  reqs
);

  logic [c_dest_nbits-1:0] 			  cur;
  assign cur = p_router_id;


  // Simple logic: We know what east and west are. we know what dest is.
  always @(*) begin
  	if (dest > cur) begin
      if (dest - cur > 4)
  			reqs = 3'b001; 
  		else
  			reqs = 3'b100;  //East: assume east is direction of increasing router numbers
  	end
    else if (cur > dest) begin
      if (cur - dest > 4)
        reqs = 3'b100;  //East: assume east is direction of increasing router numbers
      else
        reqs = 3'b001;
    end
    else // (dest == cur)
      reqs = 3'b010;
  end

endmodule

`endif  /* LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
