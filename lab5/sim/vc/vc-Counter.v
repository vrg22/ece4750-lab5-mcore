//=========================================================================
// Verilog Components: Counter
//=========================================================================

`ifndef VC_COUNTER_V
`define VC_COUNTER_V

`include "vc-regs.v"
`include "vc-assert.v"

module vc_Counter
#(
  parameter p_count_nbits       = 3,
  parameter p_count_reset_value = 0,
  parameter p_count_max_value   = 4
)(
  input  logic                     clk,
  input  logic                     reset,

  // Operations

  input  logic                     increment,
  input  logic                     decrement,

  // Outputs

  output logic [p_count_nbits-1:0] count,
  output logic                     count_is_zero,
  output logic                     count_is_max

);

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  logic [p_count_nbits-1:0] count_next;

  vc_ResetReg#( p_count_nbits, p_count_reset_value ) count_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (count_next),
    .q     (count)
  );

  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  logic do_increment;
  assign do_increment = ( increment && !decrement && (count < p_count_max_value) );

  logic do_decrement;
  assign do_decrement = ( decrement && !increment && (count > 0) );

  assign count_next
    = do_increment ? (count + 1)
    : do_decrement ? (count - 1)
    : count;

  assign count_is_zero = (count == 0);
  assign count_is_max  = (count == p_count_max_value);

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( increment );
      `VC_ASSERT_NOT_X( decrement );
    end
  end

endmodule

`endif /* VC_COUNTER_V */

