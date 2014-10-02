//=========================================================================
// Integer Multiplier Functional-Level Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_FL_V
`define LAB1_IMUL_INT_MUL_FL_V

`include "lab1-imul-msgs.v"
`include "vc-assert.v"
`include "vc-trace.v"

module lab1_imul_IntMulFL
(
  input  logic                clk,
  input  logic                reset,

  input  logic                req_val,
  output logic                req_rdy,
  input  lab1_imul_req_msg_t  req_msg,

  output logic                resp_val,
  input  logic                resp_rdy,
  output lab1_imul_resp_msg_t resp_msg
);

  //----------------------------------------------------------------------
  // Trace request message
  //----------------------------------------------------------------------

  lab1_imul_ReqMsgTrace req_msg_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (req_val),
    .rdy   (req_rdy),
    .msg   (req_msg)
  );

  //----------------------------------------------------------------------
  // Implement integer multiplication with * operator
  //----------------------------------------------------------------------

  logic [31:0] A;
  logic [31:0] B;
  logic [31:0] temp;

  logic full, req_go, resp_go, done;

  always @( posedge clk ) begin

    // Ensure that we clear the full bit if we are in reset.

    if ( reset )
      full = 0;

    // At the end of the cycle, we AND together the val/rdy bits to
    // determine if the input/output message transactions occured.

    req_go  = req_val  && req_rdy;
    resp_go = resp_val && resp_rdy;

    // If the output transaction occured, then clear the buffer full bit.
    // Note that we do this _first_ before we process the input
    // transaction so we can essentially pipeline this control logic.

    if ( resp_go )
      full = 0;

    // If the input transaction occured, then write the input message
    // into our internal buffer and update the buffer full bit.

    if ( req_go ) begin
      A    = req_msg.a;
      B    = req_msg.b;
      full = 1;
    end

    // The output message is always the product of the buffer

    resp_msg.result <= A * B;

    // The output message is valid if the buffer is full

    resp_val <= full;

  end

  // Connect output ready signal to input to ensure pipeline behavior

  assign req_rdy = resp_rdy;

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS
  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( req_val  );
      `VC_ASSERT_NOT_X( req_rdy  );
      `VC_ASSERT_NOT_X( resp_val );
      `VC_ASSERT_NOT_X( resp_rdy );
    end
  end
  `endif /* SYNTHESIS */

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] str;

  `VC_TRACE_BEGIN
  begin

    req_msg_trace.trace( trace_str );

    vc_trace.append_str( trace_str, "()" );

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

   `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_FL_V */

