//========================================================================
// Test Cases for srl instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_srl_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srl r3, r2, 0x0007   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h01000000 );

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

task init_srl_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "srl", 32'h80000000,  7, 32'h01000000 );
  test_rimm_dest_byp( 1, "srl", 32'h80000000, 14, 32'h00020000 );
  test_rimm_dest_byp( 2, "srl", 32'h80000001, 31, 32'h00000001 );

  test_rimm_src0_byp( 0, "srl", 32'h80000000,  7, 32'h01000000 );
  test_rimm_src0_byp( 1, "srl", 32'h80000000, 14, 32'h00020000 );
  test_rimm_src0_byp( 2, "srl", 32'h80000001, 31, 32'h00000001 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_srl_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "srl", 32'h80000000,  0, 32'h80000000 );
  test_rimm_op( "srl", 32'h80000000,  1, 32'h40000000 );
  test_rimm_op( "srl", 32'h80000000,  7, 32'h01000000 );
  test_rimm_op( "srl", 32'h80000000, 14, 32'h00020000 );
  test_rimm_op( "srl", 32'h80000001, 31, 32'h00000001 );

  test_rimm_op( "srl", 32'hffffffff,  0, 32'hffffffff );
  test_rimm_op( "srl", 32'hffffffff,  1, 32'h7fffffff );
  test_rimm_op( "srl", 32'hffffffff,  7, 32'h01ffffff );
  test_rimm_op( "srl", 32'hffffffff, 14, 32'h0003ffff );
  test_rimm_op( "srl", 32'hffffffff, 31, 32'h00000001 );

  test_rimm_op( "srl", 32'h21212121,  0, 32'h21212121 );
  test_rimm_op( "srl", 32'h21212121,  1, 32'h10909090 );
  test_rimm_op( "srl", 32'h21212121,  7, 32'h00424242 );
  test_rimm_op( "srl", 32'h21212121, 14, 32'h00008484 );
  test_rimm_op( "srl", 32'h21212121, 31, 32'h00000000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "srl", 32'h80000000, 7, 32'h01000000 );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_srl_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "srl", 32'h80000000, 14, 32'h00020000 );
    test_rimm_op( "srl", 32'hffffffff,  7, 32'h01ffffff );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++


//------------------------------------------------------------------------
// Test Case: srl basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "srl basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: srl bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "srl bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srl value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "srl value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srl_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srl stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "srl stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_srl_long;
  run_test;
end
`VC_TEST_CASE_END


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
