//========================================================================
// Test Cases for nor instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_nor_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000014 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nor r3, r2, r1      " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'hffffffea );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test vectors here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_nor_bypass;
begin
  clear_mem;

  address( c_reset_vector );
  
  test_rr_dest_byp( 0, "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_dest_byp( 1, "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_dest_byp( 2, "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );
  
  test_rr_src01_byp( 0, 0, "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_src01_byp( 0, 1, "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_src01_byp( 0, 2, "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );
  test_rr_src01_byp( 1, 0, "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_src01_byp( 1, 1, "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_src01_byp( 2, 0, "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );
  
  test_rr_src10_byp( 0, 0, "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_src10_byp( 0, 1, "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_src10_byp( 0, 2, "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );
  test_rr_src10_byp( 1, 0, "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_src10_byp( 1, 1, "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_src10_byp( 2, 0, "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_nor_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Logical tests
  //----------------------------------------------------------------------
  
  test_rr_op( "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_op( "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  test_rr_op( "nor", 32'h00ff00ff, 32'h0f0f0f0f, 32'hf000f000 );
  test_rr_op( "nor", 32'hf00ff00f, 32'hf0f0f0f0, 32'h0f000f00 );
  
  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------
  
  test_rr_src0_eq_dest( "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_src1_eq_dest( "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
  test_rr_srcs_eq_dest( "nor", 32'hff00ff00, 32'h00ff00ff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_nor_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "nor", 32'hff00ff00, 32'h0f0f0f0f, 32'h00f000f0 );
    test_rr_op( "nor", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h000f000f );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: nor basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "nor basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_nor_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: nor bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "nor bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_nor_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: nor value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "nor value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_nor_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: nor stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "nor stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_nor_long;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
