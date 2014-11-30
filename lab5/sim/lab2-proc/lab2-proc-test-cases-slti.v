//========================================================================
// Test Cases for slti instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_slti_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "slti r3, r2, 0x0006  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000001 );

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

task init_slti_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "slti", 15, 10, 0 );
  test_rimm_dest_byp( 1, "slti", 10, 16, 1 );
  test_rimm_dest_byp( 2, "slti", 16,  9, 0 );

  test_rimm_src0_byp( 0, "slti", 11, 15, 1 );
  test_rimm_src0_byp( 1, "slti", 17,  8, 0 );
  test_rimm_src0_byp( 2, "slti", 12, 14, 1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_slti_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "slti", 32'h00000000, 16'h0000, 32'h00000000 );
  test_rimm_op( "slti", 32'h00000001, 16'h0001, 32'h00000000 );
  test_rimm_op( "slti", 32'h00000003, 16'h0007, 32'h00000001 );
  test_rimm_op( "slti", 32'h00000007, 16'h0003, 32'h00000000 );

  test_rimm_op( "slti", 32'h00000000, 16'h8000, 32'h00000000 );
  test_rimm_op( "slti", 32'h80000000, 16'h0000, 32'h00000001 );
  test_rimm_op( "slti", 32'h80000000, 16'h8000, 32'h00000001 );

  test_rimm_op( "slti", 32'h00000000, 16'h7fff, 32'h00000001 );
  test_rimm_op( "slti", 32'h7fffffff, 16'h0000, 32'h00000000 );
  test_rimm_op( "slti", 32'h7fffffff, 16'h7fff, 32'h00000000 );

  test_rimm_op( "slti", 32'h80000000, 16'h7fff, 32'h00000001 );
  test_rimm_op( "slti", 32'h7fffffff, 16'h8000, 32'h00000000 );

  test_rimm_op( "slti", 32'h00000000, 16'hffff, 32'h00000000 );
  test_rimm_op( "slti", 32'hffffffff, 16'h0001, 32'h00000001 );
  test_rimm_op( "slti", 32'hffffffff, 16'hffff, 32'h00000000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "slti", 11, 13, 1 );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_slti_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "slti", 32'h00000101, 16'h0003, 32'h00000000 );
    test_rimm_op( "slti", 32'h00000003, 16'h0101, 32'h00000001 );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++


//------------------------------------------------------------------------
// Test Case: slti basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "slti basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: slti bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "slti bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slti value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "slti value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slti_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slti stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "slti stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_slti_long;
  run_test;
end
`VC_TEST_CASE_END


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
