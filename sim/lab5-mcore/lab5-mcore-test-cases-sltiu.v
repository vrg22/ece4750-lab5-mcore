//========================================================================
// Test Cases for sltiu instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sltiu_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000003 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sltiu r3, r2, 0x0007 " );
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

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_sltiu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "sltiu", 15, 10, 0 );
  test_rimm_dest_byp( 1, "sltiu", 10, 16, 1 );
  test_rimm_dest_byp( 2, "sltiu", 16,  9, 0 );

  test_rimm_src0_byp( 0, "sltiu", 11, 15, 1 );
  test_rimm_src0_byp( 1, "sltiu", 17,  8, 0 );
  test_rimm_src0_byp( 2, "sltiu", 12, 14, 1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sltiu_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "sltiu", 32'h00000000, 16'h0000, 32'h00000000 );
  test_rimm_op( "sltiu", 32'h00000001, 16'h0001, 32'h00000000 );
  test_rimm_op( "sltiu", 32'h00000003, 16'h0007, 32'h00000001 );
  test_rimm_op( "sltiu", 32'h00000007, 16'h0003, 32'h00000000 );

  test_rimm_op( "sltiu", 32'h00000000, 16'h8000, 32'h00000001 );
  test_rimm_op( "sltiu", 32'h80000000, 16'h0000, 32'h00000000 );
  test_rimm_op( "sltiu", 32'h80000000, 16'h8000, 32'h00000001 );

  test_rimm_op( "sltiu", 32'h00000000, 16'h7fff, 32'h00000001 );
  test_rimm_op( "sltiu", 32'h7fffffff, 16'h0000, 32'h00000000 );
  test_rimm_op( "sltiu", 32'h7fffffff, 16'h7fff, 32'h00000000 );

  test_rimm_op( "sltiu", 32'h80000000, 16'h7fff, 32'h00000000 );
  test_rimm_op( "sltiu", 32'h7fffffff, 16'h8000, 32'h00000001 );

  test_rimm_op( "sltiu", 32'h00000000, 16'hffff, 32'h00000001 );
  test_rimm_op( "sltiu", 32'hffffffff, 16'h0001, 32'h00000000 );
  test_rimm_op( "sltiu", 32'hffffffff, 16'hffff, 32'h00000000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "sltiu", 11, 13, 1 );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_sltiu_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "sltiu", 32'h80000000, 16'h7fff, 32'h00000000 );
    test_rimm_op( "sltiu", 32'h7fffffff, 16'h8000, 32'h00000001 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: sltiu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sltiu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltiu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltiu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "sltiu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltiu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltiu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sltiu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sltiu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sltiu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sltiu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sltiu_long;
  run_test;
end
`VC_TEST_CASE_END

