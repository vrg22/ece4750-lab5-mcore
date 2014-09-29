//========================================================================
// Test Cases for or instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_or_basic;
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
  inst( "or r3, r2, r1      " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000015 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

// add more test vectors here

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_or_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )
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
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Dest Bypass) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )
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
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Dest Bypass) Testing or: src0( 0xf ), src1( 0xb ), result( 0xf )
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
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );


  // (Bypass) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xf ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xf ), src1( 0xb ), result( 0xf )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "or r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );


  // (Bypass) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xf ), src1( 0xb ), result( 0xf )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

  // (Bypass) Testing or: src0( 0xf ), src1( 0xb ), result( 0xf )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "or r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf );

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

task init_or_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) or: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) or: src0( 0x1 ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) or: src0( 0x3 ), src1( 0x7 ), result( 0x7 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7 );


  // (Value Testing) or: src0( 0x0 ), src1( 0xffff8000 ), result( 0xffff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff8000 );

  // (Value Testing) or: src0( 0x80000000 ), src1( 0x0 ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) or: src0( 0x80000000 ), src1( 0xffff8000 ), result( 0xffff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff8000 );


  // (Value Testing) or: src0( 0x0 ), src1( 0x7fff ), result( 0x7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff );

  // (Value Testing) or: src0( 0x7fffffff ), src1( 0x0 ), result( 0x7fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fffffff );

  // (Value Testing) or: src0( 0x7fffffff ), src1( 0x7fff ), result( 0x7fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fffffff );


  // (Value Testing) or: src0( 0x80000000 ), src1( 0x7fff ), result( 0x80007fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80007fff );                                          

  // (Value Testing) or: src0( 0x7fffffff ), src1( 0xffff8000 ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );


  // (Value Testing) or: src0( 0x0 ), src1( 0xffffffff ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) or: src0( 0xffffffff ), src1( 0x1 ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) or: src0( 0xffffffff ), src1( 0xffffffff ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "or r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );


  //----------------------------------------------------------------------                                     
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing or: src0( 0xd ), src1( 0xb ), result( 0xf )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "or r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'hf );

  // (Src1 equals Dest) Testing or: src0( 0xe ), src1( 0xb ), result( 0xf )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "or r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // (Src0 equals Src1) Testing or: src0( 0xf ), src1( 0xf ), result( 0xf )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "or r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hf );

  // (Srcs equals Dest) Testing or: src0( 0x10 ), src1( 0x10 ), result( 0x10 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "or r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h10 );

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
task init_or_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) or: src0( 0x1 ), src1( 0x1 ), result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "or r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

    // (Value Testing) or: src0( 0x3 ), src1( 0x7 ), result( 0x7 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
    inst( "or r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7 );
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
// Test Case: or basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "or basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_basic;
  run_test;
end
`VC_TEST_CASE_END


// add more test cases here

//------------------------------------------------------------------------
// Test Case: or bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "or bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: or value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "or value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: or stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "or stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_or_long;
  run_test;
end
`VC_TEST_CASE_END



