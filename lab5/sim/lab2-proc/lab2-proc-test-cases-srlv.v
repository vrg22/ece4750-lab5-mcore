//========================================================================
// Test Cases for srlv instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_srlv_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000002 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h80000004 );
  inst( "nop                " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "srlv r3, r2, r1      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h20000001 );
  inst( "nop                  " );
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

task init_srlv_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_dest_byp( 1, "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_dest_byp( 2, "srlv", 32'h80000000, 31, 32'h00000001 );
  
  test_rr_src01_byp( 0, 0, "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_src01_byp( 0, 1, "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_src01_byp( 0, 2, "srlv", 32'h80000000, 31, 32'h00000001 );
  test_rr_src01_byp( 1, 0, "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_src01_byp( 1, 1, "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_src01_byp( 2, 0, "srlv", 32'h80000000, 31, 32'h00000001 );
  
  test_rr_src10_byp( 0, 0, "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_src10_byp( 0, 1, "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_src10_byp( 0, 2, "srlv", 32'h80000000, 31, 32'h00000001 );
  test_rr_src10_byp( 1, 0, "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_src10_byp( 1, 1, "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_src10_byp( 2, 0, "srlv", 32'h80000000, 31, 32'h00000001 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_srlv_value;
begin
  clear_mem;

  address( c_reset_vector );

  //-----------------------------------------------------------------
  // Arithmetic tests
  //-----------------------------------------------------------------
  
  test_rr_op( "srlv", 32'h80000000,  0, 32'h80000000 );
  test_rr_op( "srlv", 32'h80000000,  1, 32'h40000000 );
  test_rr_op( "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_op( "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_op( "srlv", 32'h80000001, 31, 32'h00000001 );
  test_rr_op( "srlv", 32'hffffffff,  0, 32'hffffffff );
  test_rr_op( "srlv", 32'hffffffff,  1, 32'h7fffffff );
  test_rr_op( "srlv", 32'hffffffff,  7, 32'h01ffffff );
  test_rr_op( "srlv", 32'hffffffff, 14, 32'h0003ffff );
  test_rr_op( "srlv", 32'hffffffff, 31, 32'h00000001 );
  test_rr_op( "srlv", 32'h21212121,  0, 32'h21212121 );
  test_rr_op( "srlv", 32'h21212121,  1, 32'h10909090 );
  test_rr_op( "srlv", 32'h21212121,  7, 32'h00424242 );
  test_rr_op( "srlv", 32'h21212121, 14, 32'h00008484 );
  test_rr_op( "srlv", 32'h21212121, 31, 32'h00000000 );

  // Verify that shifts only use bottom five bits
  test_rr_op( "srlv", 32'h21212121, 32'hffffffe0, 32'h21212121 );
  test_rr_op( "srlv", 32'h21212121, 32'hffffffe1, 32'h10909090 );
  test_rr_op( "srlv", 32'h21212121, 32'hffffffe7, 32'h00424242 );
  test_rr_op( "srlv", 32'h21212121, 32'hffffffee, 32'h00008484 );
  test_rr_op( "srlv", 32'h21212121, 32'hffffffff, 32'h00000000 );

  //-----------------------------------------------------------------
  // Source/Destination tests
  //-----------------------------------------------------------------
  
  test_rr_src0_eq_dest( "srlv", 32'h80000000,  7, 32'h01000000 );
  test_rr_src1_eq_dest( "srlv", 32'h80000000, 14, 32'h00020000 );
  test_rr_srcs_eq_dest( "srlv", 7, 0 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_srlv_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "srlv", 32'h80000000,  32'h00000000, 32'h80000000 );
    test_rr_op( "srlv", 32'h80000000,  32'h00000001, 32'h40000000 );
  end

  test_insert_nops( 8 );

end
endtask

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: srlv basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "srlv basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srlv_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: srlv bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "srlv bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srlv_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srlv value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "srlv value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srlv_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srlv stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "srlv stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_srlv_long;
  run_test;
end
`VC_TEST_CASE_END


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
