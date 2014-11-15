//========================================================================
// Test Cases for sllv instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sllv_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000002 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000004 );
  inst( "nop                " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sllv r3, r2, r1      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000010 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_sllv_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_dest_byp( 1, "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_dest_byp( 2, "sllv", 32'h00000001, 31, 32'h80000000 );
  
  test_rr_src01_byp( 0, 0, "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_src01_byp( 0, 1, "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_src01_byp( 0, 2, "sllv", 32'h00000001, 31, 32'h80000000 );
  test_rr_src01_byp( 1, 0, "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_src01_byp( 1, 1, "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_src01_byp( 2, 0, "sllv", 32'h00000001, 31, 32'h80000000 );
  
  test_rr_src10_byp( 0, 0, "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_src10_byp( 0, 1, "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_src10_byp( 0, 2, "sllv", 32'h00000001, 31, 32'h80000000 );
  test_rr_src10_byp( 1, 0, "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_src10_byp( 1, 1, "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_src10_byp( 2, 0, "sllv", 32'h00000001, 31, 32'h80000000 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sllv_value;
begin
  clear_mem;

  address( c_reset_vector );
  
  //-----------------------------------------------------------------
  // Arithmetic tests
  //-----------------------------------------------------------------
  
  test_rr_op( "sllv", 32'h00000001,  0, 32'h00000001 );
  test_rr_op( "sllv", 32'h00000001,  1, 32'h00000002 );
  test_rr_op( "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_op( "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_op( "sllv", 32'h00000001, 31, 32'h80000000 );
  test_rr_op( "sllv", 32'hffffffff,  0, 32'hffffffff );
  test_rr_op( "sllv", 32'hffffffff,  1, 32'hfffffffe );
  test_rr_op( "sllv", 32'hffffffff,  7, 32'hffffff80 );
  test_rr_op( "sllv", 32'hffffffff, 14, 32'hffffc000 );
  test_rr_op( "sllv", 32'hffffffff, 31, 32'h80000000 );
  test_rr_op( "sllv", 32'h21212121,  0, 32'h21212121 );
  test_rr_op( "sllv", 32'h21212121,  1, 32'h42424242 );
  test_rr_op( "sllv", 32'h21212121,  7, 32'h90909080 );
  test_rr_op( "sllv", 32'h21212121, 14, 32'h48484000 );
  test_rr_op( "sllv", 32'h21212121, 31, 32'h80000000 );

  // Verify that shifts only use bottom five bits
  test_rr_op( "sllv", 32'h21212121, 32'hffffffe0, 32'h21212121 );
  test_rr_op( "sllv", 32'h21212121, 32'hffffffe1, 32'h42424242 );
  test_rr_op( "sllv", 32'h21212121, 32'hffffffe7, 32'h90909080 );
  test_rr_op( "sllv", 32'h21212121, 32'hffffffee, 32'h48484000 );
  test_rr_op( "sllv", 32'h21212121, 32'hffffffff, 32'h80000000 );

  //-----------------------------------------------------------------
  // Source/Destination tests
  //-----------------------------------------------------------------
  test_rr_src0_eq_dest( "sllv", 32'h00000001,  7, 32'h00000080 );
  test_rr_src1_eq_dest( "sllv", 32'h00000001, 14, 32'h00004000 );
  test_rr_srcs_eq_dest( "sllv", 3, 24 );
  
  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_sllv_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "sllv", 32'h00000001,  32'h00000000, 32'h00000001 );
    test_rr_op( "sllv", 32'h00000001,  32'h00000002, 32'h00000004 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: sllv basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "sllv basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "sllv bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sllv value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sllv_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sllv stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sllv stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sllv_long;
  run_test;
end
`VC_TEST_CASE_END

