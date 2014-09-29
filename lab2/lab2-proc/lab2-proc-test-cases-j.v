//========================================================================
// Test Cases for j instruction
//========================================================================
// this file is to be `included by lab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_j_basic;
begin

  clear_mem;

  // In jump/branch tests, a bitvector tracks the paths that are taken
  // when the jumps/branches are taken / not taken. The bitvector starts
  // at 32'b0, and we raise bits in the bitvector depending on which
  // paths we take. At the end of the test, we send the bitvector to the
  // sink to check whether we took the paths we expected to take.

  address( c_reset_vector );
  // Initialize bitvector
  inst( "addiu r5, r0, 0    " );
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "j     [+7]         "); // goto 1:-.
  inst( "addiu r5, r5, 0b01 "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
  inst( "nop                "); //         |
                                //         |
  // 1:                         //         |
  inst( "addiu r5, r5, 0b10 "); // <- - - -'
  inst( "mtc0  r5, proc2mngr"); init_sink( 32'b10 );
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_j_misc;
begin

  clear_mem;

  address( c_reset_vector );

  // Initialize some data
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );

  // Initialize bitvector
  inst( "addiu r5, r0, 0    ");

  inst( "j     [+11]        ");    // goto 2:- -.
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
  inst( "j     [+5]         ");    // goto 3:-+-+-.
  inst( "addiu r5, r5, 0b100 ");   //         | | |
                                   //         | | |
  // 2:                            //         | | |
  inst( "addiu r5, r5, 0b1000 ");  // <- - - -+-' |
  inst( "j     [-4]         ");    // goto 1:-'   |
  inst( "addiu r5, r5, 0b10000 "); //             |
                                   //             |
  // 3:                            //             |
  inst( "addiu r5, r5, 0b100000 ");// <- - - - - -'

  // test branch's priority over jump
  inst( "bne   r3, r0, [+4] ");       // goto 4: -.
  inst( "j     [+2]         ");       // - -.     |
  inst( "addiu r5, r5, 0b1000000 ");  //    |     |
  inst( "addiu r5, r5, 0b10000000 "); // <--'     |
                                      //          |
  // 4:                               // < - - - -'
  inst( "mtc0  r5, proc2mngr"); init_sink( 32'b00101010 );

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
task init_j_long;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "j     [+12]        "); // goto bottom
    // send zero if fail
    inst( "mtc0  r0, proc2mngr"); // we don't expect a message here
    inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );
    inst( "j     [+10]        ");
    inst( "j     [-2]         "); // goto two above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
  end
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

//------------------------------------------------------------------------
// Test Case: j basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "j basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_j_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: j misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "j misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_j_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: j stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "j stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_j_long;
  run_test;
end
`VC_TEST_CASE_END

