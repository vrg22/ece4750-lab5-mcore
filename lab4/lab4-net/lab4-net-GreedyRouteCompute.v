//========================================================================
// Greedy Route Computation
//========================================================================

`ifndef LAB4_NET_GREEDY_ROUTE_COMPUTE_V
`define LAB4_NET_GREEDY_ROUTE_COMPUTE_V

module lab4_net_GreedyRouteCompute
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter p_num_free_nbits = 3,        

  // parameter not meant to be set outside this module
  parameter c_dest_nbits = $clog2( p_num_routers )
)
(
  input  logic [c_dest_nbits-1:0]     dest,
  output logic [2:0]                  reqs
);

  logic [c_dest_nbits-1:0] 			  cur;
  assign cur = p_router_id;


  // Route the shortest distance to destination
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

`endif  /* LAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
