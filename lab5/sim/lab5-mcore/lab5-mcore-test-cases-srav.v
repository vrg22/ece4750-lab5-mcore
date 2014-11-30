//========================================================================
// Test Cases for srav instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_srav_basic;
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
  inst( "srav r3, r2, r1      " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he0000001 );
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

task init_srav_bypass;
begin

  clear_mem;

  address( c_reset_vector );
  
  test_rr_dest_byp( 0, "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_dest_byp( 1, "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_dest_byp( 2, "srav", 32'h80000000, 31, 32'hffffffff );
  
  test_rr_src01_byp( 0, 0, "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_src01_byp( 0, 1, "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_src01_byp( 0, 2, "srav", 32'h80000000, 31, 32'hffffffff );
  test_rr_src01_byp( 1, 0, "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_src01_byp( 1, 1, "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_src01_byp( 2, 0, "srav", 32'h80000000, 31, 32'hffffffff );
  
  test_rr_src10_byp( 0, 0, "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_src10_byp( 0, 1, "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_src10_byp( 0, 2, "srav", 32'h80000000, 31, 32'hffffffff );
  test_rr_src10_byp( 1, 0, "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_src10_byp( 1, 1, "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_src10_byp( 2, 0, "srav", 32'h80000000, 31, 32'hffffffff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_srav_value;
begin
  clear_mem;

  address( c_reset_vector );
  
  //-----------------------------------------------------------------
  // Arithmetic tests
  //-----------------------------------------------------------------
  
  test_rr_op( "srav", 32'h80000000,  0, 32'h80000000 );
  test_rr_op( "srav", 32'h80000000,  1, 32'hc0000000 );
  test_rr_op( "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_op( "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_op( "srav", 32'h80000001, 31, 32'hffffffff );
  test_rr_op( "srav", 32'h7fffffff,  0, 32'h7fffffff );
  test_rr_op( "srav", 32'h7fffffff,  1, 32'h3fffffff );
  test_rr_op( "srav", 32'h7fffffff,  7, 32'h00ffffff );
  test_rr_op( "srav", 32'h7fffffff, 14, 32'h0001ffff );
  test_rr_op( "srav", 32'h7fffffff, 31, 32'h00000000 );
  test_rr_op( "srav", 32'h81818181,  0, 32'h81818181 );
  test_rr_op( "srav", 32'h81818181,  1, 32'hc0c0c0c0 );
  test_rr_op( "srav", 32'h81818181,  7, 32'hff030303 );
  test_rr_op( "srav", 32'h81818181, 14, 32'hfffe0606 );
  test_rr_op( "srav", 32'h81818181, 31, 32'hffffffff );

  // Verify that shifts only use bottom five bits
  test_rr_op( "srav", 32'h81818181, 32'hffffffe0, 32'h81818181 );
  test_rr_op( "srav", 32'h81818181, 32'hffffffe1, 32'hc0c0c0c0 );
  test_rr_op( "srav", 32'h81818181, 32'hffffffe7, 32'hff030303 );
  test_rr_op( "srav", 32'h81818181, 32'hffffffee, 32'hfffe0606 );
  test_rr_op( "srav", 32'h81818181, 32'hffffffff, 32'hffffffff );

  //-----------------------------------------------------------------
  // Source/Destination tests
  //-----------------------------------------------------------------
  
  test_rr_src0_eq_dest( "srav", 32'h80000000,  7, 32'hff000000 );
  test_rr_src1_eq_dest( "srav", 32'h80000000, 14, 32'hfffe0000 );
  test_rr_srcs_eq_dest( "srav", 7, 0 );
  
  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_srav_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "srav", 32'h80000000,  32'h00000000, 32'h80000000 );
    test_rr_op( "srav", 32'h80000000,  32'h00000001, 32'hc0000000 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: srav basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "srav basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "srav bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "srav value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_srav_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: srav stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "srav stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_srav_long;
  run_test;
end
`VC_TEST_CASE_END

