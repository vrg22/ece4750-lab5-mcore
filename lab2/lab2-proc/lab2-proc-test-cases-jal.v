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

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_jal_misc;
begin

  clear_mem;

  address( c_reset_vector );

  // Initialize some data
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );

  // Initialize bitvector
  inst( "addiu r5, r0, 0    ");

  inst( "jal     [+11]        ");  // goto 2:- -.
  inst( "addiu r5, r5, 0b1  ");    //           |
  inst( "nop                ");    //           |
  inst( "nop                ");    //           |
  inst( "nop                ");    //           |
  inst( "nop                ");    //           |
  inst( "nop                ");    //           |
  inst( "nop                ");    //           |
                                   //           |
  // 1:                            //           |
  inst( "addiu r5, r5, 0b10 ");    // <- - - -. |
  inst( "jal     [+5]         ");  // goto 3:-+-+-.
  inst( "addiu r5, r5, 0b100 ");   //         | | |
                                   //         | | |
  // 2:                            //         | | |
  inst( "addiu r5, r5, 0b1000 ");  // <- - - -+-' |
  inst( "jal     [-4]         ");  // goto 1:-'   |
  inst( "addiu r5, r5, 0b10000 "); //             |
                                   //             |
  // 3:                            //             |
  inst( "addiu r5, r5, 0b100000 ");// <- - - - - -'

  // test branch's priority over jump
  inst( "bne   r3, r0, [+4] ");       // goto 4: -.
  inst( "jal     [+2]         ");     // - -.     |
  inst( "addiu r5, r5, 0b1000000 ");  //    |     |
  inst( "addiu r5, r5, 0b10000000 "); // <--'     |
                                      //          |
  // 4:                               // < - - - -'
  inst( "mtc0  r5, proc2mngr"); init_sink( 32'b00101010 );
  inst( "mtc0  r31, proc2mngr"); init_sink( c_reset_vector + 12*4 );      //confirm the final r31

  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

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
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "jal     [+12]        "); // goto bottom
    // send zero if fail
    inst( "mtc0  r0, proc2mngr"); // we don't expect a message here
    inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );
    inst( "jal     [+10]        ");
    inst( "jal     [-2]         "); // goto two above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
    inst( "jal     [-1]         "); // goto one above
  end
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

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

//------------------------------------------------------------------------
// Test Case: jal misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "jal misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "jal stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_jal_long;
  run_test;
end
`VC_TEST_CASE_END

