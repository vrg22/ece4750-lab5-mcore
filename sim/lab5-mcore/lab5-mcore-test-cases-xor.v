//========================================================================
// Test Cases for xor instruction
//========================================================================
// this file is to be `included by lab5-mcore-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_xor_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000f0f );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000ff0 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "xor r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h000000ff );
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

task init_xor_bypass;
begin
  clear_mem;

  address( c_reset_vector );
  test_rr_dest_byp( 0, "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_dest_byp( 1, "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_dest_byp( 2, "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );
  
  test_rr_src01_byp( 0, 0, "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_src01_byp( 0, 1, "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_src01_byp( 0, 2, "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );
  test_rr_src01_byp( 1, 0, "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_src01_byp( 1, 1, "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_src01_byp( 2, 0, "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );
  
  test_rr_src10_byp( 0, 0, "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_src10_byp( 0, 1, "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_src10_byp( 0, 2, "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );
  test_rr_src10_byp( 1, 0, "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_src10_byp( 1, 1, "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_src10_byp( 2, 0, "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_xor_value;
begin
  clear_mem;

  address( c_reset_vector );
  
  //----------------------------------------------------------------------
  // Logical tests
  //----------------------------------------------------------------------
  
  test_rr_op( "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_op( "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  test_rr_op( "xor", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0ff00ff0 );
  test_rr_op( "xor", 32'hf00ff00f, 32'hf0f0f0f0, 32'h00ff00ff );
  
  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------
  
  test_rr_src0_eq_dest( "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_src1_eq_dest( "xor", 32'hff00ff00, 32'h0f0f0f0f, 32'hf00ff00f );
  test_rr_srcs_eq_dest( "xor", 32'hff00ff00, 32'h00000000 );
  
  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_xor_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "xor", 32'hf0f0f0f0, 32'h0f0f0f0f, 32'hffffffff );
    test_rr_op( "xor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hff00ff00 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: xor basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "xor basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xor_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xor bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "xor bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xor_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xor value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "xor value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_xor_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: xor stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "xor stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_xor_long;
  run_test;
end
`VC_TEST_CASE_END

