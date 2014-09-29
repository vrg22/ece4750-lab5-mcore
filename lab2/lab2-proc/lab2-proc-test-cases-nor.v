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

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_nor_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xfffffff0 )
  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Dest Bypass) Testing nor: src0( 0xe ), src1( 0xb ), result( 0xfffffff0 )
  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Dest Bypass) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xfffffff0 )
  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );


  // (Bypass) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xe ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xe ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nor  r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );


  // (Bypass) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xe ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xffffffff )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xe ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Bypass) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xfffffff0 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nor  r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  inst( "nop                  " );
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
// Value tests
//------------------------------------------------------------------------

task init_nor_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) nor: src0( 0x0 ), src1( 0x0 ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) nor: src0( 0x1 ), src1( 0x1 ), result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Value Testing) nor: src0( 0x3 ), src1( 0x7 ), result( 0xfffffff8 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff8 );


  // (Value Testing) nor: src0( 0x0 ), src1( 0xffff8000 ), result( 0x7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff );

  // (Value Testing) nor: src0( 0x0 ), src1( 0x1 ), result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Value Testing) nor: src0( 0xffffffff ), src1( 0xffffffff ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Value Testing) nor: src0( 0xf ), src1( 0x0 ), result( 0xfffffff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Value Testing) nor: src0( 0xffffffff ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) nor: src0( 0x7fffffff ), src1( 0x7fff ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );


  // (Value Testing) nor: src0( 0x80000000 ), src1( 0x7fff ), result( 0x7fff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff8000 );                                          

  // (Value Testing) nor: src0( 0x7fffffff ), src1( 0xffff8000 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  // (Value Testing) nor: src0( 0x0 ), src1( 0xffffffff ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) nor: src0( 0xfffffff0 ), src1( 0x1 ), result( 0xe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hfffffff0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'he );

  // (Value Testing) nor: src0( 0x0 ), src1( 0x0 ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "nor  r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );


  //----------------------------------------------------------------------                                     
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing nor: src0( 0xd ), src1( 0xb ), result( 0xfffffff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nor  r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Src1 equals Dest) Testing nor: src0( 0xf ), src1( 0xb ), result( 0xfffffff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nor  r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Src0 equals Src1) Testing nor: src0( 0xf ), src1( 0xf ), result( 0xfffffff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nor  r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hfffffff0 );

  // (Srcs equals Dest) Testing nor: src0( 0x10 ), src1( 0x10 ), result( 0xffffffef )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "nor  r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'hffffffef );

  inst( "nop                  " );
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
// Long tests
//------------------------------------------------------------------------

integer idx;
task init_nor_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) nor: src0( 0x1 ), src1( 0x1 ), result( 0xfffffffe )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "nor  r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

    // (Value Testing) nor: src0( 0x3 ), src1( 0x7 ), result( 0xfffffff8 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
    inst( "nor  r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffff8 );
  end

  inst( "nop                  " );
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
// Test Case: nor basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "nor basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_nor_basic;
  run_test;
end
`VC_TEST_CASE_END


// add more test cases here

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