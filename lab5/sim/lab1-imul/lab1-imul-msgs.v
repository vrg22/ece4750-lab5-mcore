//========================================================================
// ex-imul-msgs : Integer Multiplier Request/Response Messages
//========================================================================

`ifndef LAB1_IMUL_MSGS_V
`define LAB1_IMUL_MSGS_V

`include "vc-trace.v"

//------------------------------------------------------------------------
// Integer Multiplier Request Message
//------------------------------------------------------------------------
// An imul request message simply contains two 32b operands.
//
//   63       32 31        0
//  +-----------+-----------+
//  | operand a | operand b |
//  +-----------+-----------+
//

`define LAB1_IMUL_REQ_MSG_A_NBITS 32
`define LAB1_IMUL_REQ_MSG_B_NBITS 32

typedef struct packed {
  logic [`LAB1_IMUL_REQ_MSG_A_NBITS-1:0] a;
  logic [`LAB1_IMUL_REQ_MSG_B_NBITS-1:0] b;
} lab1_imul_req_msg_t;

//------------------------------------------------------------------------
// Trace request message
//------------------------------------------------------------------------
// We use this module to create a line trace for a request message being
// passed over a val/rdy interface, and to also enable us to easily see
// the fields in the message from gtkwave (i.e., we can just view the
// field variables within this module instance).

module lab1_imul_ReqMsgTrace
(
  input logic               clk,
  input logic               reset,
  input logic               val,
  input logic               rdy,
  input lab1_imul_req_msg_t msg

);

  // Extract fields

  logic [`LAB1_IMUL_REQ_MSG_A_NBITS-1:0] a;
  logic [`LAB1_IMUL_REQ_MSG_B_NBITS-1:0] b;

  assign a = msg.a;
  assign b = msg.b;

  // Line tracing

  `ifndef SYNTHESIS

  localparam c_msg_nbits = $bits(lab1_imul_req_msg_t);
  logic [(`VC_TRACE_NBITS_TO_NCHARS(c_msg_nbits)+1)*8-1:0] str;

  `VC_TRACE_BEGIN
  begin
    $sformat( str, "%x:%x", msg.a, msg.b );
    vc_trace.append_val_rdy_str( trace_str, val, rdy, str );
  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

//------------------------------------------------------------------------
// Integer Multiplier Response Message
//------------------------------------------------------------------------
// An imul response message is just a single 32b bit vector. Using a
// struct is probably overkill here since there is only a single field,
// but it helps maintain the idea that we often use structs to create
// message types.
//
//   15        0
//  +-----------+
//  | result    |
//  +-----------+
//

`define LAB1_IMUL_RESP_MSG_RESULT_NBITS 32

typedef struct packed {
  logic [`LAB1_IMUL_RESP_MSG_RESULT_NBITS-1:0] result;
} lab1_imul_resp_msg_t;

`endif /* LAB1_IMUL_MSGS_V */

