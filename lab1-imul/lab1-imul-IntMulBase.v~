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

 localparam c_nbits = `LAB1_IMUL_REQ_MSG_A_NBITS;

  // A Mux

  logic [c_nbits-1:0] b_reg_out;      //How to organize to avoid implicit def?
  logic [c_nbits-1:0] sub_out;
  logic [c_nbits-1:0] a_mux_out;
  logic [c_nbits-1:0] l_shift_out;
  logic [c_nbits-1:0] r_shift_out; 
  logic [c_nbits-1:0] rslt_mux_out;
  logic [c_nbits-1:0] add_mux_out;
  logic [c_nbits-1:0] rslt_reg_out;

  vc_Mux2#(c_nbits) a_mux
  (
    .sel   (cs.a_mux_sel),
    .in0   (l_shift_out),    //NAME? <<
    .in1   (req_msg.a),
    .out   (a_mux_out)
  );

  // A register

  logic [c_nbits-1:0] a_reg_out;

  vc_ResetReg#(c_nbits) a_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (a_mux_out),
    .q     (a_reg_out)
  );

  // B Mux

  logic [c_nbits-1:0] b_mux_out;

  vc_Mux2#(c_nbits) b_mux
  (
    .sel   (cs.b_mux_sel),
    .in0   (r_shift_out),     //NAME? >>
    .in1   (req_msg.b),
    .out   (b_mux_out)
  );

  // B register

  vc_ResetReg#(c_nbits) b_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (b_mux_out),
    .q     (b_reg_out)
  );

  assign ss.b_lsb = b_reg_out[0]; //CHECK

  // Result Mux

  //rslt_mux_out defined above
  vc_Mux2#(c_nbits) rslt_mux
  (
    .sel   (cs.result_mux_sel),
    .in0   (add_mux_out),
    .in1   (32'b0),
    .out   (rslt_mux_out)
  );

  // Result register

  //rslt_reg_out defined above
  vc_EnReg#(c_nbits) rslt_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (cs.result_en),
    .d     (rslt_mux_out),
    .q     (rslt_reg_out)
  );

  // Right Shifter

  //r_shift_out defined above
  vc_RightLogicalShifter#(c_nbits, 1'b1) r_shift
  (  
    //Default shamt val is fine; still need to/should specify??
    .in     (b_reg_out),
    .out    (r_shift_out),
    .shamt  (1'b1)
  );

  // Left Shifter

  //l_shift_out defined above
  vc_LeftLogicalShifter#(c_nbits, 1'b1) l_shift
  (
    //Default shamt val is fine; still need to/should specify?
    .in     (a_reg_out),
    .out    (l_shift_out),
    .shamt  (1'b1)
  );
  
  // Adder

  logic [c_nbits-1:0] adder_out;

  vc_SimpleAdder#(c_nbits) adder  //simple or regular?
  (
    //
    .in0    (a_reg_out),
    .in1    (rslt_reg_out),
    .out    (adder_out)
  );

  // Add Mux
 
  //add_mux_out defined above
  vc_Mux2#(c_nbits) add_mux
  (
    .sel   (cs.add_mux_sel),
    .in0   (adder_out),
    .in1   (rslt_reg_out),
    .out   (add_mux_out)
  );

  // Set response message

  assign resp_msg.result = rslt_reg_out;

endmodule

//========================================================================
// Control Unit
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

  // Control and status signals

  output lab1_imul_cs_t           cs,
  input  lab1_imul_ss_t           ss
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
  logic [5:0] counter; //DOES THIS GO HERE?

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
      counter <= 1'b0; //0;
    end
    else begin
      counter <= counter + 1;
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
  assign is_calc_done = (counter == 32);

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
  
  //CONVENTION: mux path's from diagram,
  //top to bottom go 0 to max value (???)
  localparam x   = 1'dx;
  localparam tmp   = 1'd0;


  task set_cs
  (
    input logic       cs_req_rdy,
    input logic       cs_resp_val,
    input logic       cs_a_mux_sel,
    input logic       cs_b_mux_sel,
    input logic       cs_result_mux_sel,
    input logic       cs_result_en,
    input logic       cs_add_mux_sel
  );
  begin
    req_rdy      = cs_req_rdy;
    resp_val     = cs_resp_val;
    cs.a_mux_sel = cs_a_mux_sel;
    cs.b_mux_sel = cs_b_mux_sel;
    cs.result_mux_sel = cs_result_mux_sel;
    cs.result_en = cs_result_en;
    cs.add_mux_sel = cs_add_mux_sel;
  end
  endtask

  // Labels for Mealy transistions

  logic do_add_shift;
  logic do_shift;

  assign do_add_shift = (counter < 32) && (ss.b_lsb == 1);
  assign do_shift  = (counter < 32) && (ss.b_lsb == 0);

  // Set outputs using a control signal "table"

  always @(*) begin

    set_cs( 0, 0, x, x, x, 0, x );                         //CHECK!!!!
    case ( state_reg )
      //req resp a mux b mux result mux result add mux
      //rdy val  sel   sel   sel        en     sel
      STATE_IDLE:               set_cs( 1,  0,  1,  1,  1,  1,  x ); //x?
      STATE_CALC: 
        if ( do_add_shift )     set_cs( 0,  0,  0,  0,  0,  1,  0 );
        else if ( do_shift )    set_cs( 0,  0,  0,  0,  0,  0,  1 );
      STATE_DONE:               set_cs( 0,  1,  x,  x,  x,  0,  x );

    endcase

  end


endmodule


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

  //----------------------------------------------------------------------
  // Control and Status Signals
  //----------------------------------------------------------------------

  lab1_imul_cs_t cs;
  lab1_imul_ss_t ss;

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  lab1_imul_IntMulBaseCtrl ctrl
  (
    .clk      (clk),
    .reset    (reset),

    .req_val  (req_val),
    .req_rdy  (req_rdy),
    .resp_val (resp_val),
    .resp_rdy (resp_rdy),

    .cs       (cs),
    .ss       (ss)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  lab1_imul_IntMulBaseDpath dpath
  (
    .clk      (clk),
    .reset    (reset),

    .req_msg  (req_msg),
    .resp_msg (resp_msg),

    .cs       (cs),
    .ss       (ss)
  );

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

