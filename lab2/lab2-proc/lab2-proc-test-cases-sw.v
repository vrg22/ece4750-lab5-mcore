//========================================================================
// Test Cases for sw instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sw_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src(   32'h00002000 );
  inst( "mfc0  r5, mngr2proc " ); init_src(   32'h00000001 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "sw    r5, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "lw    r4, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "mtc0  r4, proc2mngr " ); init_sink(  32'h00000001 );

  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_sw_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing sw: offset( 0x0 ), base( 0x2000 ), result( 0xff )  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  inst( "sw r2, 0x0(r1)  " );
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );

  // (Dest Bypass) Testing sw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );  
  inst( "sw r2, 0x4(r1)  " );
  inst( "lw r3, 0x4(r1)  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Dest Bypass) Testing sw: offset( 0x0 ), base( 0x2004 ), result( 0x7f01 )  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f01 );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f01 );

  // (Dest Bypass) Testing sw: offset( 0x4 ), base( 0x2004 ), result( 0xabcd0ff0 )  // dest_nops( 3 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'habcd0ff0 );
  inst( "sw r2, 0x4(r1)  " );  
  inst( "lw r3, 0x4(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Dest Bypass) Testing sw: offset( 0x0 ), base( 0x200c ), result( 0x700f )  // dest_nops( 4 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h700f );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h700f );


  // (Src0 Bypass) Testing sw: offset( 0x0 ), base( 0x2000 ), result( 0xff )  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );

  // (Src0 Bypass) Testing sw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )  // src0_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  inst( "nop                  " );
  inst( "sw r2, 0x4(r1)  " );  
  inst( "lw r3, 0x4(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Src0 Bypass) Testing sw: offset( 0x0 ), base( 0x2004 ), result( 0x7f00 )  // src0_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Src0 Bypass) Testing sw: offset( 0x4 ), base( 0x2004 ), result( 0xabcd0ff0 )  // src0_nops( 3 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'habcd0ff0 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sw r2, 0x4(r1)  " );  
  inst( "lw r3, 0x4(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Src0 Bypass) Testing lw: offset( 0x0 ), base( 0x200c ), result( 0x700f )  // src0_nops( 4 )
  
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h700f );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h700f );

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

task init_sw_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Value tests
  //----------------------------------------------------------------------

  // (Value) Testing sw: offset( 0x0 ), base( 0x2000 ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  inst( "sw r2, 0x0(r1)  " );  
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );

  // // (Value) Testing sw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  // inst( "sw r2, 0x4(r1)  " ); 
  // inst( "lw r3, 0x4(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

  // // (Value) Testing sw: offset( 0x8 ), base( 0x2000 ), result( 0xabcd0ff0 )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'habcd0ff0 );
  // inst( "sw r2, 0x8(r1)  " ); 
  // inst( "lw r3, 0x8(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // // (Value) Testing sw: offset( 0xc ), base( 0x2000 ), result( 0x700f )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h700f );
  // inst( "sw r2, 0xc(r1)  " ); 
  // inst( "lw r3, 0xc(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h700f );

  // // (Value) Testing sw: offset( -0xc ), base( 0x200c ), result( 0xff )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  // inst( "sw r2, -12(r1)  " );
  // inst( "lw r3, -12(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );

  // // (Value) Testing sw: offset( -0x8 ), base( 0x200c ), result( 0x7f00 )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  // inst( "sw r2, -8(r1)  " );
  // inst( "lw r3, -8(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

  // // (Value) Testing sw: offset( -0x4 ), base( 0x200c ), result( 0xabcd0ff0 )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'habcd0ff0 );
  // inst( "sw r2, -4(r1)  " );
  // inst( "lw r3, -4(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // // (Value) Testing sw: offset( 0x0 ), base( 0x200c ), result( 0x700f )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h700f );
  // inst( "sw r2, 0x0(r1)  " );
  // inst( "lw r3, 0x0(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h700f );


  // // Test with a negative base

  // // (Value) Testing sw: offset( 0x3000 ), base( -0x1000 ), result( 0xff )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  -32'h00001000 );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  // inst( "sw r2, 0x3000(r1)  " );
  // inst( "lw r3, 0x3000(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );


  // // Test with unaligned base

  // // (Value) Testing sw: offset( 0x7 ), base( 0x1ffd ), result( 0x7f00 )

  // inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1ffd );
  // inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  // inst( "sw r2, 0x7(r1)  " );
  // inst( "lw r3, 0x7(r1)  " );
  // inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );


  // //----------------------------------------------------------------------
  // // Test WAW Hazard
  // //----------------------------------------------------------------------

  // inst( "mfc0 r1, mngr2proc" ); init_src(  32'h00002000 );
  // inst( "mfc0 r2, mngr2proc" ); init_src(  32'h00000002 );
  // inst( "sw   r2, 0(r1)    " );
  // inst( "lw   r3, 0(r1)    " );
  // inst( "addu r3, r1, r2   " );
  // inst( "mtc0 r3, proc2mngr" ); init_sink( 32'h00002002 );

  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );
  // inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_sw_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
  // (Value) Testing lw: offset( 0x0 ), base( 0x2000 ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'hff );
  inst( "sw r2, 0x0(r1)  " );
  inst( "lw r3, 0x0(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hff );

  // (Value) Testing lw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h7f00 );
  inst( "sw r2, 0x4(r1)  " );
  inst( "lw r3, 0x4(r1)  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h7f00 );

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
// VVADD
//------------------------------------------------------------------------

task init_sw_vvadd;
begin
  clear_mem;
  address( c_reset_vector );
  inst( "mfc0  r4, mngr2proc " ); init_src(   32'h00002000 );
  inst( "mfc0  r6, mngr2proc " ); init_src(   32'h00000001 );
  inst( "mfc0  r7, mngr2proc " ); init_src( 7 );
  inst( "addu  r8, r6, r7    " );
  inst( "sw    r8, 0(r4)     " );
  inst( "lw    r10, 0(r4)    " );
  inst( "mtc0  r10, proc2mngr" ); init_sink( 8 );
  inst( "nop                 " );
  inst( "nop                 " );


end
endtask

//------------------------------------------------------------------------
// Test Case: sw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "sw bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "sw value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "sw stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sw_long;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: SW VVADD TEST
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(5, "sw vvadd" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_vvadd;
  run_test;
end
`VC_TEST_CASE_END



