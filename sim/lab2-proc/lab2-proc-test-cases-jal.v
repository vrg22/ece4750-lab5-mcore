//========================================================================
// Test Cases for jal instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_jal_basic;
begin

  // In jump/branch tests, a bitvector tracks the paths that are taken
  // when the jumps/branches are taken / not taken. The bitvector starts
  // at 32'b0, and we raise bits in the bitvector depending on which
  // paths we take. At the end of the test, we send the bitvector to the
  // sink to check whether we took the paths we expected to take.

  clear_mem;

  address( c_reset_vector );
  // Initialize bitvector
  inst( "addiu r5, r0, 0     ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "jal   [+7]          "); // goto 1:
  inst( "addiu r5, r5, 0b01  "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
  inst( "nop                 "); //         |
                                 //         |
  // 1:                          //         |
  inst( "addiu r5, r5, 0b10  "); // <- - - -'
  inst( "mtc0  r5, proc2mngr "); init_sink( 32'b10 );
  inst( "mtc0  r31, proc2mngr"); init_sink( c_reset_vector + 7*4 );

  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");
  inst( "nop                 ");

end
endtask

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test vectors here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_jal_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_jal_dest_byp( 0, "jal" );
  test_jal_dest_byp( 1, "jal" );
  test_jal_dest_byp( 2, "jal" );
  test_jal_dest_byp( 3, "jal" );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_jal_misc;
begin

  clear_mem;

  address( c_reset_vector );


  // note: we are setting the sinks here in order because the code jumps
  // backwards as well, but sinks always happen in order

  // msg 1
  init_sink( c_reset_vector +  2 * 4 );
  // msg 2
  init_sink( c_reset_vector + 14 * 4 );
  // msg 3
  init_sink( c_reset_vector + 11 * 4 );

  inst( "mfc0  r3, mngr2proc " ); init_src( 32'h00000001 );
  inst( "jal   [+11]         " ); // goto 2:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr " ); // we don't expect a message here
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // 1:
  // pass
  // check the correct PC
  inst( "mtc0  r31, proc2mngr" ); // expect msg 2
  inst( "jal   [+5]          " ); // goto 3:
  // fail
  inst( "mtc0  r0, proc2mngr " );

  // 2:
  // pass
  inst( "mtc0  r31, proc2mngr" ); // expect msg 1
  inst( "jal   [-4]          " ); // goto 1:
  // fail
  inst( "mtc0  r0, proc2mngr " );
  // 3:
  // pass
  inst( "mtc0  r31, proc2mngr" ); // expect msg 3

  // test branch's priority over jump
  inst( "bne   r3, r0, [+4]  " ); // goto 5:
  inst( "jal     [+2]        " );
  inst( "mtc0  r0, proc2mngr " );

  // 4:
  // fail
  inst( "mtc0  r0, proc2mngr " );
  // 5:
  // pass -- check that r31 is not corrupt
  inst( "mtc0  r31, proc2mngr" ); init_sink( c_reset_vector + 11 * 4 );


  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_jal_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_jal_dest_byp( 0, "jal" );
  end

  test_insert_nops( 8 );

end
endtask


//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: jal basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "jal basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++


//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: jal bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "jal bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "jal misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "jal stall/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_jal_long;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
