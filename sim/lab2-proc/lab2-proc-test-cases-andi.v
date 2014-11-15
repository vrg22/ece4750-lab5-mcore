//========================================================================
// Test Cases for andi instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_andi_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "andi r3, r2, 0x0004 " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000004 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test vectors here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_andi_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "andi", 32'h0ff00ff0, 32'h0f0f, 32'h00000f00 );
  test_rimm_dest_byp( 1, "andi", 32'h00ff00ff, 32'hf0f0, 32'h000000f0 );
  test_rimm_dest_byp( 2, "andi", 32'hf00ff00f, 32'h0f0f, 32'h0000000f );

  test_rimm_src0_byp( 0, "andi", 32'h0ff00ff0, 32'h0f0f, 32'h00000f00 );
  test_rimm_src0_byp( 1, "andi", 32'h00ff00ff, 32'hf0f0, 32'h000000f0 );
  test_rimm_src0_byp( 2, "andi", 32'hf00ff00f, 32'h0f0f, 32'h0000000f );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_andi_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Logical
  //----------------------------------------------------------------------

  test_rimm_op( "andi", 32'hff00ff00, 16'h0f0f, 32'h00000f00 );
  test_rimm_op( "andi", 32'h0ff00ff0, 32'hf0f0, 32'h000000f0 );
  test_rimm_op( "andi", 32'h00ff00ff, 32'h0f0f, 32'h0000000f );
  test_rimm_op( "andi", 32'hf00ff00f, 32'hf0f0, 32'h0000f000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "andi", 32'hff00ff00, 32'hf0f0, 32'h0000f000 );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_andi_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "andi", 32'h00000003, 16'h0007, 32'h00000003 );
    test_rimm_op( "andi", 32'h00000008, 16'h000f, 32'h00000008 );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++


//------------------------------------------------------------------------
// Test Case: andi basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "andi basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: andi bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "andi bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: andi value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "andi value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_andi_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: andi stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "andi stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_andi_long;
  run_test;
end
`VC_TEST_CASE_END


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
