//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

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
  logic [5:0] shift_amt;        // shift amount for shifters

} lab1_imul_cs_t;

// Status signals (dpath->ctrl)

typedef struct packed {

  logic [31:0] b_out;           // B register output

} lab1_imul_ss_t;


//========================================================================
// Datapath
//========================================================================

module lab1_imul_IntMulAltDpath
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

  assign ss.b_out = b_reg_out;    //status signal

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
  vc_RightLogicalShifter#(c_nbits, 6) r_shift
  (  
    .in     (b_reg_out),
    .out    (r_shift_out),
    .shamt  (cs.shift_amt)
  );

  // Left Shifter

  //l_shift_out defined above
  vc_LeftLogicalShifter#(c_nbits, 6) l_shift
  (
    .in     (a_reg_out),
    .out    (l_shift_out),
    .shamt  (cs.shift_amt)
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

module lab1_imul_IntMulAltCtrl
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
  logic [5:0] counter; //CONSIDER USING ACTUAL MODULE

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
      counter <= 0;
    end
    else begin
      if ( state_reg == STATE_CALC ) begin
        counter <= counter + cs.shift_amt;  // + 1          //Enclose in if-statement for safety?
      end
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
  assign is_calc_done = (counter == 32);  //should be ==, can test w/>=

  always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE: if ( req_go    ) begin
                    state_next = STATE_CALC;
                    counter = 0;
                  end
      STATE_CALC: 
                  if ( is_calc_done ) begin
                    state_next = STATE_DONE;
                  end
      STATE_DONE: if ( resp_go   )    state_next = STATE_IDLE;

    endcase

  end

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------
  
  //CONVENTION: mux path's from diagram,
  //top to bottom go 0 to max value => good practice?
  localparam x   = 1'bx; //1'b0;
  //localparam tmp   = 1'd0;


  task set_cs
  (
    input logic       cs_req_rdy,
    input logic       cs_resp_val,
    input logic       cs_a_mux_sel,
    input logic       cs_b_mux_sel,
    input logic       cs_result_mux_sel,
    input logic       cs_result_en,
    input logic       cs_add_mux_sel,
    input logic [5:0] cs_shift_amt
  );
  begin
    req_rdy      = cs_req_rdy;
    resp_val     = cs_resp_val;
    cs.a_mux_sel = cs_a_mux_sel;
    cs.b_mux_sel = cs_b_mux_sel;
    cs.result_mux_sel = cs_result_mux_sel;
    cs.result_en = cs_result_en;
    cs.add_mux_sel = cs_add_mux_sel;
    cs.shift_amt   = cs_shift_amt;
  end
  endtask

  // Labels for Mealy transistions

  logic [5:0] shift_amt;
  logic do_add_shift;
  logic do_shift;

  //assign shift_amt = cs.shift_amt;
  assign do_add_shift = (counter < 32) && (ss.b_out[0] == 1);       //CHECK
  assign do_shift  = (counter < 32); //&& (ss.b_out[0] == 0);

  // Set outputs using a control signal "table"

  always @(*) begin

    set_cs( 0, 0, x, x, x, 0, x, 6'bxxxxxx );             //CHECK
    casez ( ss.b_out )

      32'b_????_????_????_????_????_????_????_?100_     :     shift_amt = 6'd2;
      32'b_????_????_????_????_????_????_????_1000_     :     shift_amt = 6'd3;
      32'b_????_????_????_????_????_????_???1_0000_     :     shift_amt = 6'd4;
      32'b_????_????_????_????_????_????_??10_0000_     :     shift_amt = 6'd5;
      32'b_????_????_????_????_????_????_?100_0000_     :     shift_amt = 6'd6;
      32'b_????_????_????_????_????_????_1000_0000_     :     shift_amt = 6'd7;
      32'b_????_????_????_????_????_???1_0000_0000_     :     shift_amt = 6'd8;
      32'b_????_????_????_????_????_??10_0000_0000_     :     shift_amt = 6'd9;
      32'b_????_????_????_????_????_?100_0000_0000_     :     shift_amt = 6'd10;
      32'b_????_????_????_????_????_1000_0000_0000_     :     shift_amt = 6'd11;
      32'b_????_????_????_????_???1_0000_0000_0000_     :     shift_amt = 6'd12;
      32'b_????_????_????_????_??10_0000_0000_0000_     :     shift_amt = 6'd13;
      32'b_????_????_????_????_?100_0000_0000_0000_     :     shift_amt = 6'd14;
      32'b_????_????_????_????_1000_0000_0000_0000_     :     shift_amt = 6'd15;
      32'b_????_????_????_???1_0000_0000_0000_0000_     :     shift_amt = 6'd16;
      32'b_????_????_????_??10_0000_0000_0000_0000_     :     shift_amt = 6'd17;
      32'b_????_????_????_?100_0000_0000_0000_0000_     :     shift_amt = 6'd18;
      32'b_????_????_????_1000_0000_0000_0000_0000_     :     shift_amt = 6'd19;
      32'b_????_????_???1_0000_0000_0000_0000_0000_     :     shift_amt = 6'd20;
      32'b_????_????_??10_0000_0000_0000_0000_0000_     :     shift_amt = 6'd21;
      32'b_????_????_?100_0000_0000_0000_0000_0000_     :     shift_amt = 6'd22;
      32'b_????_????_1000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd23;
      32'b_????_???1_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd24;
      32'b_????_??10_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd25;
      32'b_????_?100_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd26;
      32'b_????_1000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd27;
      32'b_???1_0000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd28;
      32'b_??10_0000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd29;
      32'b_?100_0000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd30;
      32'b_1000_0000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd31;
      //32'b_0000_0000_0000_0000_0000_0000_0000_0000_     :     shift_amt = 6'd32;  //comment out?
      default          :     shift_amt = 6'd1;

      /*
      32'h???????C     :     shift_amt = 6'd2;
      32'h???????8     :     shift_amt = 6'd3;
      32'h???????0     :     shift_amt = 6'd4;
      32'h??????E0     :     shift_amt = 6'd5;
      32'h??????C0     :     shift_amt = 6'd6;
      32'h??????80     :     shift_amt = 6'd7;
      32'h??????00     :     shift_amt = 6'd8;
      32'h?????E00     :     shift_amt = 6'd9;
      32'h?????C00     :     shift_amt = 6'd10;
      32'h?????800     :     shift_amt = 6'd11;
      32'h?????000     :     shift_amt = 6'd12;
      32'h????E000     :     shift_amt = 6'd13;
      32'h????C000     :     shift_amt = 6'd14;
      32'h????8000     :     shift_amt = 6'd15;
      32'h????0000     :     shift_amt = 6'd16;
      32'h???E0000     :     shift_amt = 6'd17;
      32'h???C0000     :     shift_amt = 6'd18;
      32'h???80000     :     shift_amt = 6'd19;
      32'h???00000     :     shift_amt = 6'd20;
      32'h??E00000     :     shift_amt = 6'd21;
      32'h??C00000     :     shift_amt = 6'd22;
      32'h??800000     :     shift_amt = 6'd23;
      32'h??000000     :     shift_amt = 6'd24;
      32'h?E000000     :     shift_amt = 6'd25;
      32'h?C000000     :     shift_amt = 6'd26;
      32'h?8000000     :     shift_amt = 6'd27;
      32'h?0000000     :     shift_amt = 6'd28;
      32'hE0000000     :     shift_amt = 6'd29;
      32'hC0000000     :     shift_amt = 6'd30;
      32'h80000000     :     shift_amt = 6'd31;
      32'h00000000     :     shift_amt = 6'd32;
      default          :     shift_amt = 6'd1;
      */

    endcase


    case ( state_reg )
      //req resp a mux b mux result mux result add mux shift
      //rdy val  sel   sel   sel        en     sel     amt
      STATE_IDLE:               set_cs( 1,  0,  1,  1,  1,  1,  x, shift_amt/*1*/ ); //shift_amt should be 1)dont care or 2)1?
      STATE_CALC: 
        if ( do_add_shift )     set_cs( 0,  0,  0,  0,  0,  1,  0, shift_amt /*1*/ ); //shift_amt should be 1
        else if ( do_shift )    set_cs( 0,  0,  0,  0,  x,  0,  x, shift_amt /*1*/ ); //shift_amt should be determined by casez statement
      STATE_DONE:               set_cs( 0,  1,  x,  x,  x,  0,  x, 6'bxxxxxx/*shift_amt*/ ); //shift_amt should be don't care

    endcase

  end


endmodule




//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

module lab1_imul_IntMulAlt
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

  lab1_imul_IntMulAltCtrl ctrl
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

  lab1_imul_IntMulAltDpath dpath
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

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_ALT_V */
