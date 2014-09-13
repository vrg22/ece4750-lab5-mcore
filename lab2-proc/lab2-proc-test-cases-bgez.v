//========================================================================
// Test Cases for bgez instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_bgez_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc  "); init_src(  32'd0 );
  inst( "mfc0  r2, mngr2proc  "); init_src(  32'hfffffffe );
  inst( "mfc0  r1, mngr2proc  "); init_src(  32'd1 );
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "bgez   r3,  [+8]     "); // goto 2: (branch taken)
  // 1: send zero if fail
  inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");

  // 2:
  inst( "mtc0  r1, proc2mngr  "); init_sink(  32'h00000001 );
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "bgez   r2, [+2]   "); // goto 3: (branch not taken)
  inst( "bgez   r3, [+2]   "); // goto 4: (branch taken)
  // 3:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
  // 4:
  inst( "mtc0  r1, proc2mngr  "); init_sink(  32'h00000001 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

// add more test vectors here

//------------------------------------------------------------------------
// Test Case: bgez basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "bgez basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_bgez_basic;
  run_test;
end
`VC_TEST_CASE_END

// add more test cases here


