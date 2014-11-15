//========================================================================
// Unit Tests for Pipelined Processor ALU
//========================================================================

`include "lab2-proc-alu.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab2-proc-alu" )

  //----------------------------------------------------------------------
  // Test lab2_proc_alu
  //----------------------------------------------------------------------

  logic [31:0] t1_in0;
  logic [31:0] t1_in1;
  logic [ 3:0] t1_fn;

  logic [31:0] t1_out;

  lab2_proc_alu t1_alu
  (
    .in0  (t1_in0),
    .in1  (t1_in1),
    .fn   (t1_fn),
    .out  (t1_out)
  );

  task t1
  (
    input logic [31:0] in0,
    input logic [31:0] in1,
    input logic [ 3:0] fn,

    input logic [31:0] out
  );
  begin
    t1_in0 = in0;
    t1_in1 = in1;
    t1_fn  = fn;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in0, in1, fn );
    `VC_TEST_NET( t1_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "lab2_proc_alu" )
  begin

    //  in0           in1           fn     out
    // add
    t1( 32'h00000000, 32'h00000000, 4'd0,  32'h00000000 );
    t1( 32'h0ffaa660, 32'h00012304, 4'd0,  32'h0ffbc964 );
    // pos-neg
    t1( 32'h00132050, 32'hd6620040, 4'd0,  32'hd6752090 );
    t1( 32'hfff0a440, 32'h00004450, 4'd0,  32'hfff0e890 );
    // neg-neg
    t1( 32'hfeeeeaa3, 32'hf4650000, 4'd0,  32'hf353eaa3 );
    // sub
    t1( 32'h00000000, 32'h00000000, 4'd1,  32'h00000000 );
    t1( 32'h0ffaa660, 32'h00012304, 4'd1,  32'h0ff9835c );
    // pos-neg
    t1( 32'h00132050, 32'hd6620040, 4'd1,  32'h29b12010 );
    t1( 32'hfff0a440, 32'h00004450, 4'd1,  32'hfff05ff0 );
    // neg-neg
    t1( 32'hfeeeeaa3, 32'hf4650000, 4'd1,  32'h0a89eaa3 );
//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here for other ALU ops!

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
    // sll
    t1( 32'h00000000, 32'h0fff3390, 4'd2,  32'h0fff3390 );
    t1( 32'h00000005, 32'h0fff3390, 4'd2,  32'hffe67200 );
    // or
    t1( 32'ha5501120, 32'h0fdfd008, 4'd3,  32'hafdfd128 );
    // slt
    t1( 32'h00000000, 32'h00000000, 4'd4,  32'h00000000 );
    t1( 32'h0ffaa660, 32'h00012304, 4'd4,  32'h00000000 );
    t1( 32'h00eaa660, 32'h01012304, 4'd4,  32'h00000001 );
    // pos-neg
    t1( 32'h00132050, 32'hd6620040, 4'd4,  32'h00000000 );
    t1( 32'hfff0a440, 32'h00004450, 4'd4,  32'h00000001 );
    // neg-neg
    t1( 32'hfeeeeaa3, 32'hf4650000, 4'd4,  32'h00000000 );
    t1( 32'hfeeeeaa3, 32'hfff50000, 4'd4,  32'h00000001 );
    // sltu
    t1( 32'h00000000, 32'h00000000, 4'd5,  32'h00000000 );
    t1( 32'h0ffaa660, 32'h00012304, 4'd5,  32'h00000000 );
    t1( 32'h00eaa660, 32'h01012304, 4'd5,  32'h00000001 );
    // pos-neg
    t1( 32'h00132050, 32'hd6620040, 4'd5,  32'h00000001 );
    t1( 32'hfff0a440, 32'h00004450, 4'd5,  32'h00000000 );
    // neg-neg
    t1( 32'hfeeeeaa3, 32'hf4650000, 4'd5,  32'h00000000 );
    t1( 32'hfeeeeaa3, 32'hfff50000, 4'd5,  32'h00000001 );
    // and
    t1( 32'ha5501120, 32'h0fdfd008, 4'd6,  32'h05501000 );
    // xor
    t1( 32'ha5501120, 32'h0fdfd008, 4'd7,  32'haa8fc128 );
    // nor
    t1( 32'ha5501120, 32'h0fdfd008, 4'd8,  32'h50202ed7 );
    // srl
    t1( 32'h00000000, 32'h0fff3390, 4'd9,  32'h0fff3390 );
    t1( 32'h00000005, 32'h0fff3390, 4'd9,  32'h007ff99c );
    t1( 32'h00000007, 32'h8fff3390, 4'd9,  32'h011ffe67 );
    // sra
    t1( 32'h00000000, 32'h0fff3390, 4'd10, 32'h0fff3390 );
    t1( 32'h00000005, 32'h0fff3390, 4'd10, 32'h007ff99c );
    t1( 32'h00000007, 32'h8fff3390, 4'd10, 32'hff1ffe67 );
    // cp op0
    t1( 32'hf00baa00, 32'h0cafe000, 4'd11, 32'hf00baa00 );
    // cp op1
    t1( 32'hf00baa00, 32'h0cafe000, 4'd12, 32'h0cafe000 );
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++


  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

