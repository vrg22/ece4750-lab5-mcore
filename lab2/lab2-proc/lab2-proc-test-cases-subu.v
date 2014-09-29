//========================================================================
// Test Cases for subu instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_subu_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000004 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "subu r3, r1, r2    " );
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

task init_subu_bypass;                //REVISE AFTER IMPLEMENTING ALTERNATIVE DESIGN -> HOW do nops test bypassing?
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing subu: src0( 0xd ), src1( 0xb ), result( 0x2 )
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
  inst( "subu r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

  // (Dest Bypass) Testing subu: src0( 0xe ), src1( 0xb ), result( 0x3 )
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
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3 );

  // (Dest Bypass) Testing subu: src0( 0xf ), src1( 0xb ), result( 0x4 )
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
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h4 );


  // (Bypass) Testing subu: src0( 0xd ), src1( 0xb ), result( 0x2 )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

  // (Bypass) Testing subu: src0( 0xe ), src1( 0xb ), result( 0x3 )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3 );

  // (Bypass) Testing subu: src0( 0xf ), src1( 0xb ), result( 0x4 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h4 );

  // (Bypass) Testing subu: src0( 0xd ), src1( 0xb ), result( 0x2 )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h2 );

  // (Bypass) Testing subu: src0( 0xe ), src1( 0xb ), result( 0x3 )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h3 );

  // (Bypass) Testing subu: src0( 0xf ), src1( 0xb ), result( 0x4 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "subu r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h4 );


  // (Bypass) Testing subu: src0( 0xd ), src1( 0xb ), result( 0xfffffffe )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Bypass) Testing subu: src0( 0xe ), src1( 0xb ), result( 0xfffffffd )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffd );

  // (Bypass) Testing subu: src0( 0xf ), src1( 0xb ), result( 0xfffffffc )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffc );

  // (Bypass) Testing subu: src0( 0xd ), src1( 0xb ), result( 0xfffffffe )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Bypass) Testing subu: src0( 0xe ), src1( 0xb ), result( 0xfffffffd )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffd );

  // (Bypass) Testing subu: src0( 0xf ), src1( 0xb ), result( 0xfffffffc )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "subu r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffc );

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

task init_subu_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) subu: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) subu: src0( 0x1 ), src1( 0x1 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) subu: src0( 0x3 ), src1( 0x7 ), result( 0xfffffffc )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffc );


  // (Value Testing) subu: src0( 0xffff8000 ), src1( 0x0 ), result( 0xffff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff8000 );

  // (Value Testing) subu: src0( 0x80000000 ), src1( 0x0 ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) subu: src0( 0xffff8000 ), src1( 0x80000000 ), result( 0x7fff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff8000 );


  // (Value Testing) subu: src0( 0x7fff ), src1( 0x0 ), result( 0x7fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff );

  // (Value Testing) subu: src0( 0x7fffffff ), src1( 0x0 ), result( 0x7fffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fffffff );

  // (Value Testing) subu: src0( 0x7fffffff ), src1( 0x7fff ), result( 0x7fff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff8000 );


  // (Value Testing) subu: src0( 0x80000000 ), src1( 0x7fff ), result( 0x7fff8001 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7fff );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7fff8001 );

  // (Value Testing) subu: src0( 0x7fffffff ), src1( 0xffff8000 ), result( 0x80007fff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80007fff );


  // (Value Testing) subu: src0( 0x0 ), src1( 0xffffffff ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) subu: src0( 0xffffffff ), src1( 0x1 ), result( 0xfffffffe )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hfffffffe );

  // (Value Testing) subu: src0( 0xffffffff ), src1( 0xffffffff ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "subu r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );


  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing subu: src0( 0xd ), src1( 0xb ), result( 0x2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "subu r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h2 );

  // (Src1 equals Dest) Testing subu: src0( 0xe ), src1( 0xb ), result( 0x3 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "subu r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h3 );

  // (Src0 equals Src1) Testing subu: src0( 0xf ), src1( 0xf ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "subu r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h0 );

  // (Srcs equals Dest) Testing subu: src0( 0x10 ), src1( 0x10 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "subu r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h0 );

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
task init_subu_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) subu: src0( 0x1 ), src1( 0x1 ), result( 0x0 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "subu r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

    // (Value Testing) subu: src0( 0x7 ), src1( 0x3 ), result( 0x4 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
    inst( "subu r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h4 );
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
// Test Case: subu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "subu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_basic;
  run_test;
end
`VC_TEST_CASE_END


//------------------------------------------------------------------------
// Test Case: subu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "subu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_bypass;
  run_test;
end
`VC_TEST_CASE_END


//------------------------------------------------------------------------
// Test Case: subu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "subu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: subu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "subu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_subu_long;
  run_test;
end
`VC_TEST_CASE_END

