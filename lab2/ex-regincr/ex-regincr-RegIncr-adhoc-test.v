//========================================================================
// RegIncr Ad-Hoc Testing
//========================================================================
// This is an example of ad-hoc testing which does not use any specific
// unit testing framework.

`include "ex-regincr-RegIncr.v"

module top;

  // Clocking

  logic clk = 1;
  always #5 clk = ~clk;

  // Instaniate the device-under-test

  logic [7:0] in;
  logic [7:0] out;

  ex_regincr_RegIncr reg_incr
  (
    .clk (clk),
    .in  (in),
    .out (out)
  );

  // Verify functionality

  initial begin

    // Dump waveforms

    $dumpfile("ex-regincr-RegIncr-test.vcd");
    $dumpvars;

    #1;

    // Test cases

    in = 8'h00;
    #10;
    if ( out != 8'h02 ) begin
      $display( "ERROR: out, expected = %x, actual = %x", 8'h02, out );
      $finish;
    end

    in = 8'h13;
    #10;
    if ( out != 8'h15 ) begin
      $display( "ERROR: out, expected = %x, actual = %x", 8'h15, out );
      $finish;
    end

    in = 8'h27;
    #10;
    if ( out != 8'h29 ) begin
      $display( "ERROR: out, expected = %x, actual = %x", 8'h29, out );
      $finish;
    end

    $display( "*** PASSED ***" );
    $finish;
  end

endmodule

