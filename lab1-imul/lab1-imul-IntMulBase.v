//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "lab1-imul-msgs.v"
`include "vc-assert.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-arithmetic.v"
`include "vc-trace.v"


// Define datapath and control unit here
//========================================================================
// Control and status signal structs
//========================================================================

// Control signals (ctrl->dpath)

typedef struct packed {

  logic       result_en;        // Enable for result register
  logic       b_reg_en;         // Enable for B register
  logic       a_mux_sel;        // Sel for mux in front of A reg
  logic       b_mux_sel;        // sel for mux in front of B reg
  logic       result_mux_sel;   // sel for mux in front of result reg
  logic       add_mux_sel;      // sel for mux in back of adder

} lab1_imul_cs_t;

// Status signals (dpath->ctrl)

typedef struct packed {

  logic       b_lsb;      // value of B's least-sig-bit

} lab1_imul_ss_t;


//========================================================================
// Datapath
//========================================================================

module lab1_imul_IntMulBaseDpath
(
  input  logic             clk,
  input  logic             reset,

  // Data signals

  input  lab1_imul_req_msg_t  req_msg,
  output lab1_imul_resp_msg_t resp_msg,

  // Control and status signals

  input  lab1_imul_cs_t       cs,
  output lab1_imul_ss_t       ss
);

//INSERT MODULES HERE!!!

endmodule

//========================================================================
// Control
//========================================================================

module lab1_imul_IntMulBaseCtrl
(
  input  logic                 clk,
  input  logic                 reset,

  // Dataflow signals

  input  logic                 req_val,
  output logic                 req_rdy,
  output logic                 resp_val,
  input  logic                 resp_rdy,

  // Control and satus signals

  output ex_gcd_cs_t           cs,
  input  ex_gcd_ss_t           ss
);

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  typedef enum logic [$clog2(3)-1:0] {
    STATE_IDLE,
    STATE_CALC,
    STATE_DONE
  } state_t;

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  state_t state_reg;
  state_t state_next;

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
    end
    else begin
      state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  logic req_go;
  logic resp_go;
  logic is_calc_done;

  assign req_go       = req_val  && req_rdy;
  assign resp_go      = resp_val && resp_rdy;
  assign is_calc_done = !ss.is_a_lt_b && ss.is_b_zero;

  always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE: if ( req_go    )    state_next = STATE_CALC;
      STATE_CALC: if ( is_calc_done ) state_next = STATE_DONE;
      STATE_DONE: if ( resp_go   )    state_next = STATE_IDLE;

    endcase

  end

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------

  localparam a_x   = 2'dx;
  localparam a_ld  = 2'd0;
  localparam a_b   = 2'd1;
  localparam a_sub = 2'd2;

  localparam b_x   = 1'dx;
  localparam b_ld  = 1'd0;
  localparam b_a   = 1'd1;

  task set_cs
  (
    input logic       cs_req_rdy,
    input logic       cs_resp_val,
    input logic [1:0] cs_a_mux_sel,
    input logic       cs_a_reg_en,
    input logic       cs_b_mux_sel,
    input logic       cs_b_reg_en
  );
  begin
    req_rdy      = cs_req_rdy;
    resp_val     = cs_resp_val;
    cs.a_reg_en  = cs_a_reg_en;
    cs.b_reg_en  = cs_b_reg_en;
    cs.a_mux_sel = cs_a_mux_sel;
    cs.b_mux_sel = cs_b_mux_sel;
  end
  endtask

  // Labels for Mealy transistions

  logic do_swap;
  logic do_sub;

  assign do_swap = ss.is_a_lt_b;
  assign do_sub  = !ss.is_b_zero;

  // Set outputs using a control signal "table"

  always @(*) begin

    set_cs( 0, 0, a_x, 0, b_x, 0 );
    case ( state_reg )
      //                                 req resp a mux  a  b mux b
      //                                 rdy val  sel    en sel   en
      STATE_IDLE:                set_cs( 1,  0,   a_ld,  1, b_ld, 1 );
      STATE_CALC: if ( do_swap ) set_cs( 0,  0,   a_b,   1, b_a,  1 );
             else if ( do_sub  ) set_cs( 0,  0,   a_sub, 1, b_x,  0 );
      STATE_DONE:                set_cs( 0,  1,   a_x,   0, b_x,  0 );

    endcase

  end





//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module lab1_imul_IntMulBase
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

  // Instantiate datapath and control models here and then connect them
  // together. As a place holder, for now we simply pass input operand
  // A through to the output, which obviously is not correct.

  assign req_rdy         = resp_rdy;
  assign resp_val        = req_val;
  assign resp_msg.result = req_msg.a;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] str;

  `VC_TRACE_BEGIN
  begin

    req_msg_trace.trace( trace_str );

    vc_trace.append_str( trace_str, "(" );

    // Add extra line tracing for internal state here

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_BASE_V */

