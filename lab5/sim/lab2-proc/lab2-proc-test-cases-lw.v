//========================================================================
// Test Cases for lw instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_lw_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src(   32'h00002000 );
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
  inst( "mtc0  r4, proc2mngr " ); init_sink(  32'hcafecafe );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  address( 32'h2000 );
  data( 32'hcafecafe );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_lw_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  // (Dest Bypass) Testing lw: offset( 0x0 ), base( 0x2000 ), result( 0xff )  // dest_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );

  // (Dest Bypass) Testing lw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )  // dest_nops( 1 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Dest Bypass) Testing lw: offset( 0x0 ), base( 0x2004 ), result( 0x7f00 )  // dest_nops( 2 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Dest Bypass) Testing lw: offset( 0x4 ), base( 0x2004 ), result( 0xabcd0ff0 )  // dest_nops( 3 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Dest Bypass) Testing lw: offset( 0x0 ), base( 0x200c ), result( 0x700f )  // dest_nops( 4 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, 0x0(r1)  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h700f );


  // (Src0 Bypass) Testing lw: offset( 0x0 ), base( 0x2000 ), result( 0xff )  // src0_nops( 0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );

  // (Src0 Bypass) Testing lw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )  // src0_nops( 1 )

  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Src0 Bypass) Testing lw: offset( 0x0 ), base( 0x2004 ), result( 0x7f00 )  // src0_nops( 2 )

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Src0 Bypass) Testing lw: offset( 0x4 ), base( 0x2004 ), result( 0xabcd0ff0 )  // src0_nops( 3 )

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2004 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Src0 Bypass) Testing lw: offset( 0x0 ), base( 0x200c ), result( 0x700f )  // src0_nops( 4 )

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h700f );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

  // initialize data
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
  data( 32'h0000700f );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_lw_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Value tests
  //----------------------------------------------------------------------

  // (Value) Testing lw: offset( 0x0 ), base( 0x2000 ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );

  // (Value) Testing lw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Value) Testing lw: offset( 0x8 ), base( 0x2000 ), result( 0xabcd0ff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x8(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Value) Testing lw: offset( 0xc ), base( 0x2000 ), result( 0x700f )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0xc(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h700f );

  // (Value) Testing lw: offset( -0xc ), base( 0x200c ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, -12(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );

  // (Value) Testing lw: offset( -0x8 ), base( 0x200c ), result( 0x7f00 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, -8(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  // (Value) Testing lw: offset( -0x4 ), base( 0x200c ), result( 0xabcd0ff0 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, -4(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'habcd0ff0 );

  // (Value) Testing lw: offset( 0x0 ), base( 0x200c ), result( 0x700f )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h200c );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h700f );


  // Test with a negative base

  // (Value) Testing lw: offset( 0x3000 ), base( -0x1000 ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  -32'h00001000 );
  inst( "lw r2, 0x3000(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );


  // Test with unaligned base

  // (Value) Testing lw: offset( 0x7 ), base( 0x1ffd ), result( 0x7f00 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h1ffd );
  inst( "lw r2, 0x7(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );


  //----------------------------------------------------------------------
  // Test WAW Hazard
  //----------------------------------------------------------------------

  inst( "mfc0 r1, mngr2proc" ); init_src(  32'h00002000 );
  inst( "mfc0 r2, mngr2proc" ); init_src(  32'h00000002 );
  inst( "lw   r3, 0(r1)    " );
  inst( "addu r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr" ); init_sink( 32'h00002002 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

  // initialize data
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
  data( 32'h0000700f );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_lw_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
  // (Value) Testing lw: offset( 0x0 ), base( 0x2000 ), result( 0xff )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x0(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'hff );

  // (Value) Testing lw: offset( 0x4 ), base( 0x2000 ), result( 0x7f00 )

  inst( "mfc0 r1, mngr2proc   " ); init_src(  32'h2000 );
  inst( "lw r2, 0x4(r1)  " );
  inst( "mtc0 r2, proc2mngr   " ); init_sink( 32'h7f00 );

  end

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

  // initialize data
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
  data( 32'h0000700f );

end
endtask


//------------------------------------------------------------------------
// Test Case: lw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "lw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "lw bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "lw value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "lw stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_lw_long;
  run_test;
end
`VC_TEST_CASE_END

