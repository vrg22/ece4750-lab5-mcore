//========================================================================
// Test Cases for xori instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_xori_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "xori r3, r2, 0x0002  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000007 );

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

task init_xori_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "xori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0ff00 );
  test_rimm_dest_byp( 1, "xori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0ff0 );
  test_rimm_dest_byp( 2, "xori", 32'hf00ff00f, 16'hf0f0, 32'hf00f00ff );

  test_rimm_src0_byp( 0, "xori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0ff00 );
  test_rimm_src0_byp( 1, "xori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0ff0 );
  test_rimm_src0_byp( 2, "xori", 32'hf00ff00f, 16'hf0f0, 32'hf00f00ff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_xori_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Logical tests
  //----------------------------------------------------------------------

  test_rimm_op( "xori", 32'hff00ff00, 16'h0f0f, 32'hff00f00f );
  test_rimm_op( "xori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0ff00 );
  test_rimm_op( "xori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0ff0 );
  test_rimm_op( "xori", 32'hf00ff00f, 16'hf0f0, 32'hf00f00ff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "xori", 32'hff00ff00, 16'h0f0f, 32'hff00f00f );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_xori_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "xori", 32'h0000000a, 16'h0005, 32'h0000000f );
    test_rimm_op( "xori", 32'h00000002, 16'h0005, 32'h00000007 );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++


//------------------------------------------------------------------------
// Test Case: xori basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "xori basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: xori bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "xori bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xori value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "xori value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xori_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xori stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "xori stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_xori_long;
  run_test;
end
`VC_TEST_CASE_END


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
