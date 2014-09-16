//========================================================================
// Unit Tests for Pipelined Processor Register File
//========================================================================

`include "lab2-proc-regfile.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "lab2-proc-regfile" )

  //----------------------------------------------------------------------
  // Test lab2_proc_Regfile
  //----------------------------------------------------------------------

  logic        t1_reset;

  logic [ 4:0] t1_read_addr0;
  logic [31:0] t1_read_data0;

  logic [ 4:0] t1_read_addr1;
  logic [31:0] t1_read_data1;

  logic        t1_write_en;
  logic [ 4:0] t1_write_addr;
  logic [31:0] t1_write_data;

  lab2_proc_Regfile t1_regfile
  (
    .clk          (clk),
    .reset        (t1_reset),

    .read_addr0   (t1_read_addr0),
    .read_data0   (t1_read_data0),

    .read_addr1   (t1_read_addr1),
    .read_data1   (t1_read_data1),

    .write_en     (t1_write_en),
    .write_addr   (t1_write_addr),
    .write_data   (t1_write_data)
  );

  task t1
  (
    input logic [ 4:0]  read_addr0,
    input logic [31:0]  read_data0,

    input logic [ 4:0]  read_addr1,
    input logic [31:0]  read_data1,

    input logic         write_en,
    input logic [ 4:0]  write_addr,
    input logic [31:0]  write_data
  );
  begin
    t1_read_addr0 = read_addr0;
    t1_read_addr1 = read_addr1;
    t1_write_en   = write_en;
    t1_write_addr = write_addr;
    t1_write_data = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr0, read_data0, read_addr1, read_data1 );
    `VC_TEST_NOTE_INPUTS_3( write_en, write_addr, write_data );
    `VC_TEST_NET( t1_read_data0, read_data0 );
    `VC_TEST_NET( t1_read_data1, read_data1 );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "lab2_proc_Regfile" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;


    //  -- read0 --  -- read1 --  --- write ---
    //  addr data    addr data    wen addr data

    t1( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx );

    // Cold read 0, should be 0

    t1( 'h0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t1( 'hx, 'h??,   'h0, 'h00,   0, 'hx, 'hxx );
    t1( 'h0, 'h00,   'h0, 'h00,   0, 'hx, 'hxx );

    // Write an entry and read it -- we expect it to be 0

    t1( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t1(   0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t1( 'hx, 'h??,     0, 'h00,   0, 'hx, 'hxx );
    t1(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );

    // Fill with entries then read

    t1( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   1, 'hbb );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   2, 'hcc );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   3, 'hdd );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   4, 'hee );

    t1(   0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t1( 'hx, 'h??,     1, 'hbb,   0, 'hx, 'hxx );
    t1(   2, 'hcc,   'hx, 'h??,   0, 'hx, 'hxx );
    t1( 'hx, 'h??,     3, 'hdd,   0, 'hx, 'hxx );
    t1(   4, 'hee,   'hx, 'h??,   0, 'hx, 'hxx );

    t1(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );
    t1(   1, 'hbb,     1, 'hbb,   0, 'hx, 'hxx );
    t1(   2, 'hcc,     2, 'hcc,   0, 'hx, 'hxx );
    t1(   3, 'hdd,     3, 'hdd,   0, 'hx, 'hxx );
    t1(   4, 'hee,     4, 'hee,   0, 'hx, 'hxx );

    // Overwrite entries and read again

    t1( 'hx, 'h??,   'hx, 'h??,   1,   0, 'h00 );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   1, 'h11 );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   2, 'h22 );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   3, 'h33 );
    t1( 'hx, 'h??,   'hx, 'h??,   1,   4, 'h44 );

    t1(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );
    t1(   1, 'h11,     1, 'h11,   0, 'hx, 'hxx );
    t1(   2, 'h22,     2, 'h22,   0, 'hx, 'hxx );
    t1(   3, 'h33,     3, 'h33,   0, 'hx, 'hxx );
    t1(   4, 'h44,     4, 'h44,   0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t1(   1, 'h11,     2, 'h22,   1,   0, 'h0a );
    t1(   2, 'h22,     3, 'h33,   1,   1, 'h1b );
    t1(   3, 'h33,     4, 'h44,   1,   2, 'h2c );
    t1(   4, 'h44,     0, 'h00,   1,   3, 'h3d );
    t1(   0, 'h00,     1, 'h1b,   1,   4, 'h4e );

    // Concurrent read/writes (to same addr)

    t1(   0, 'h00,     0, 'h00,   1,   0, 'h5a );
    t1(   1, 'h1b,     1, 'h1b,   1,   1, 'h6b );
    t1(   2, 'h2c,     2, 'h2c,   1,   2, 'h7c );
    t1(   3, 'h3d,     3, 'h3d,   1,   3, 'h8d );
    t1(   4, 'h4e,     4, 'h4e,   1,   4, 'h9e );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

