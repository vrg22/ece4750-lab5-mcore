//========================================================================
// Test Cases for sltu instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sltu_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000001 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "sltu r3, r2, r1    " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000001 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_sltu_bypass;
begin
  clear_mem;

  address( c_reset_vector );
  
  test_rr_dest_byp( 0, "sltu", 11, 13, 1 );
  test_rr_dest_byp( 1, "sltu", 14, 13, 0 );
  test_rr_dest_byp( 2, "sltu", 12, 13, 1 );
  
  test_rr_src01_byp( 0, 0, "sltu", 14, 13, 0 );
  test_rr_src01_byp( 0, 1, "sltu", 11, 13, 1 );
  test_rr_src01_byp( 0, 2, "sltu", 15, 13, 0 );
  test_rr_src01_byp( 1, 0, "sltu", 10, 13, 1 );
  test_rr_src01_byp( 1, 1, "sltu", 16, 13, 0 );
  test_rr_src01_byp( 2, 0, "sltu",  9, 13, 1 );
  
  test_rr_src10_byp( 0, 0, "sltu", 17, 13, 0 );
  test_rr_src10_byp( 0, 1, "sltu",  8, 13, 1 );
  test_rr_src10_byp( 0, 2, "sltu", 18, 13, 0 );
  test_rr_src10_byp( 1, 0, "sltu",  7, 13, 1 );
  test_rr_src10_byp( 1, 1, "sltu", 19, 13, 0 );
  test_rr_src10_byp( 2, 0, "sltu",  6, 13, 1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sltu_value;
begin
  clear_mem;

  address( c_reset_vector );

  //-----------------------------------------------------------------
  // Arithmetic tests
  //-----------------------------------------------------------------
      
  test_rr_op( "sltu", 32'h00000000, 32'h00000000, 0 );
  test_rr_op( "sltu", 32'h00000001, 32'h00000001, 0 );
  test_rr_op( "sltu", 32'h00000003, 32'h00000007, 1 );
  test_rr_op( "sltu", 32'h00000007, 32'h00000003, 0 );
  test_rr_op( "sltu", 32'h00000000, 32'hffff8000, 1 );
  test_rr_op( "sltu", 32'h80000000, 32'h00000000, 0 );
  test_rr_op( "sltu", 32'h80000000, 32'hffff8000, 1 );
  test_rr_op( "sltu", 32'h00000000, 32'h00007fff, 1 );
  test_rr_op( "sltu", 32'h7fffffff, 32'h00000000, 0 );
  test_rr_op( "sltu", 32'h7fffffff, 32'h00007fff, 0 );
  test_rr_op( "sltu", 32'h80000000, 32'h00007fff, 0 );
  test_rr_op( "sltu", 32'h7fffffff, 32'hffff8000, 1 );
  test_rr_op( "sltu", 32'h00000000, 32'hffffffff, 1 );
  test_rr_op( "sltu", 32'hffffffff, 32'h00000001, 0 );
  test_rr_op( "sltu", 32'hffffffff, 32'hffffffff, 0 );

  //-----------------------------------------------------------------
  // Source/Destination tests
  //-----------------------------------------------------------------
      
  test_rr_src0_eq_dest( "sltu", 14, 13, 0 );
  test_rr_src1_eq_dest( "sltu", 11, 13, 1 );
  test_rr_srcs_eq_dest( "sltu", 13, 0 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_sltu_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "sltu", 32'h00000001, 32'h00000001, 0 );
    test_rr_op( "sltu", 32'h00000003, 32'h00000007, 1 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: sltu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "sltu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "sltu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sltu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sltu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sltu_long;
  run_test;
end
`VC_TEST_CASE_END

