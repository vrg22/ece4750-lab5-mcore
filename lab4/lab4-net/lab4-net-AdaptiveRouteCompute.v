//========================================================================
// Adaptive Route Computation
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

  logic [c_dest_nbits-1:0] 			      cur;
  assign cur = p_router_id;

  logic [p_num_routers-1:0]           east_hops;
  logic [p_num_routers-1:0]           west_hops;
  logic [8:0]                         east_factor;
  logic [8:0]                         west_factor;


  // Compute hops and load factors in either direction. Route along path with minimal load factor
  
  always @(*) begin
    // destination = current router
    if (dest == cur) begin
      reqs = 3'b010;
    end
    // destination > current router
    else if (dest > cur) begin
      east_hops = dest-cur;
      west_hops = p_num_routers-(dest-cur);
      // destination is only one hop away so don't need to check two hops away
      if (dest-cur == 1) begin
        east_factor = (f-forw_free_one) + east_hops;
        west_factor = (f-backw_free_one) + west_hops;
      end
      // destination is more than one hop away
      else begin
        east_factor = (f-forw_free_one) + (f-forw_free_two) + east_hops;
        west_factor = (f-backw_free_one) + (f-backw_free_two) + west_hops;
      end
      // route along path with minimal load factor. east if factors are equal
      if(west_factor < east_factor) begin
        reqs = 3'b001;
      end
      else begin
        reqs = 3'b100;
      end
    end
    // destination < current router
    else begin
      west_hops = cur-dest;
      east_hops = p_num_routers-(cur-dest);
      // destination is only one hop away so don't need to check two hops away
      if (cur-dest == 1) begin
        east_factor = (f-forw_free_one) + east_hops;
        west_factor = (f-backw_free_one) + west_hops;
      end
      // destination is more than one hop away
      else begin
        east_factor = (f-forw_free_one) + (f-forw_free_two) + east_hops;
        west_factor = (f-backw_free_one) + (f-backw_free_two) + west_hops;  
      end
      // route along path with minimal load factor. east if factors are equal
      if(west_factor < east_factor) begin
        reqs = 3'b001;
      end
      else begin
        reqs = 3'b100;
      end 
    end
  end


endmodule

`endif  /* LAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
