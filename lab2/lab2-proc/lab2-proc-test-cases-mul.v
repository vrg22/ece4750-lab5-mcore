//========================================================================
// Test Cases for mul instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_mul_basic;
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
  inst( "mul r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000014 );
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

task init_mul_bypass;                //REVISE AFTER IMPLEMENTING ALTERNATIVE DESIGN -> HOW do nops test bypassing?
begin
  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing mul: src0( 0xd ), src1( 0xb ), result( 0x8f )
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
  inst( "mul r3, r1, r2      " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8f );

  // (Dest Bypass) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )
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
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9a );

  // (Dest Bypass) Testing mul: src0( 0xf ), src1( 0xb ), result( 0xa5 )
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
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha5 );


  // (Bypass) Testing mul: src0( 0xd ), src1( 0xb ), result( 0x8f )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8f );

  // (Bypass) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9a );

  // (Bypass) Testing mul: src0( 0xf ), src1( 0xb ), result( 0xa5 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha5 );

  // (Bypass) Testing mul: src0( 0xd ), src1( 0xb ), result( 0x8f )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8f );

  // (Bypass) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9a );

  // (Bypass) Testing mul: src0( 0xf ), src1( 0xb ), result( 0x4 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src0 loaded before src1

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r3, r1, r2    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha5 );


  // (Bypass) Testing mul: src0( 0xad ), src1( 0xd1 ), result( 0x8d3d )
  // src0_nops( 0 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'had );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd1 );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8d3d );

  // (Bypass) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )
  // src0_nops( 0 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9a );

  // (Bypass) Testing mul: src0( 0xf ), src1( 0xb ), result( 0xa5 )
  // src0_nops( 0 ), src1_nops( 2 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha5 );

  // (Bypass) Testing mul: src0( 0xd ), src1( 0xb ), result( 0x8f )
  // src0_nops( 1 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "nop                  " );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8f );

  // (Bypass) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )
  // src0_nops( 1 ), src1_nops( 1 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "nop                  " );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h9a );

  // (Bypass) Testing mul: src0( 0xf ), src1( 0xb ), result( 0xa5 )
  // src0_nops( 2 ), src1_nops( 0 )
  // - src1 loaded before src0

  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mul r3, r2, r1    " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'ha5 );

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

task init_mul_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  // (Value Testing) mul: src0( 0x0 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h0 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) mul: src0( 0x1 ), src1( 0x1 ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

  // (Value Testing) mul: src0( 0x3 ), src1( 0x7 ), result( 0x15 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h3 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h15 );


  // (Value Testing) mul: src0( 0xffff8000 ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff8000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) mul: src0( 0x80000000 ), src1( 0x1 ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h80000000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h80000000 );

  // (Value Testing) mul: src0( 0xffff800 ), src1( 0x10 ), result( 0xffff8000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff800 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff8000 );


  // (Value Testing) mul: src0( 0x7fff ), src1( 0x0 ), result( 0x0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7fff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h0 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h0 );

  // (Value Testing) mul: src0( 0x1234 ), src1( 0x1 ), result( 0x1234 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1234 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1234 );

  // (Value Testing) mul: src0( 0xffff ), src1( 0x10000 ), result( 0xffff0000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h10000 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffff0000 );


  // (Value Testing) mul: src0( 0x8000 ), src1( 0x1 ), result( 0x80000000 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h8000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h8000 );

  // (Value Testing) mul: src0( 0xffffffff ), src1( 0xffffffff ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  -32'h1 );   //Two's complement
  inst( "mfc0 r2, mngr2proc   " ); init_src(  -32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );


  // (Value Testing) mul: src0( 0x2 ), src1( 0xffffffff ), result( -0x2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff ); //-1
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( -32'h2 );

  // (Value Testing) mul: src0( 0xffffffff ), src1( 0x1 ), result( 0xffffffff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hffffffff );

  // (Value Testing) mul: src0( 0xffffffff ), src1( 0xffffffff ), result( 0x1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hffffffff );
  inst( "mul r3, r1, r2    " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );


  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  // (Src0 equals Dest) Testing mul: src0( 0xd ), src1( 0xb ), result( 0x8f )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hd );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r1, r1, r2    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h8f );

  // (Src1 equals Dest) Testing mul: src0( 0xe ), src1( 0xb ), result( 0x9a )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'he );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hb );
  inst( "mul r2, r1, r2    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h9a );

  // (Src0 equals Src1) Testing mul: src0( 0xf ), src1( 0xf ), result( 0xe1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'hf );
  inst( "mul r2, r1, r1    " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'he1 );

  // (Srcs equals Dest) Testing mul: src0( 0x10 ), src1( 0x10 ), result( 0x100 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h10 );
  inst( "mul r1, r1, r1    " );
  inst( "mtc0 r1, proc2mngr   " ); init_sink( 32'h100 );

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
task init_mul_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    // (Value Testing) mul: src0( 0x1 ), src1( 0x1 ), result( 0x1 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h1 );
    inst( "mul r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h1 );

    // (Value Testing) mul: src0( 0x7 ), src1( 0x3 ), result( 0x15 )
    inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h7 );
    inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h3 );
    inst( "mul r3, r1, r2    " );
    inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h15 );
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
// Test Case: mul basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "mul basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_basic;
  run_test;
end
`VC_TEST_CASE_END


//------------------------------------------------------------------------
// Test Case: mul bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "mul bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_bypass;
  run_test;
end
`VC_TEST_CASE_END


//------------------------------------------------------------------------
// Test Case: mul value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "mul value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: mul stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "mul stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_mul_long;
  run_test;
end
`VC_TEST_CASE_END