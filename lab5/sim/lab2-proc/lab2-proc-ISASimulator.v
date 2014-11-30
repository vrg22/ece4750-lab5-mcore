//=========================================================================
// PARCV2 ISA Simulator
//=========================================================================

`ifndef LAB2_PROC_ISA_SIM_V
`define LAB2_PROC_ISA_SIM_V

`include "vc-trace.v"
`include "pisa-inst.v"

`define LAB2_PROC_FROM_MNGR_MSG_NBITS 32
`define LAB2_PROC_TO_MNGR_MSG_NBITS 32

module lab2_proc_ISASimulator
#(
  parameter p_mem_nbytes   = 1024, // size of physical memory in bytes
  parameter p_opaque_nbits = 8,    // mem message opaque field num bits
  parameter p_addr_nbits   = 32,   // mem message address num bits
  parameter p_data_nbits   = 32,   // mem message data num bits

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(
  input  logic                                      clk,
  input  logic                                      reset,

  // clears the content of memory

  input  logic                                      mem_clear,

  // maximum delay

  input  logic [31:0]                               max_delay,

  // From mngr streaming port

  input  logic [`LAB2_PROC_FROM_MNGR_MSG_NBITS-1:0] from_mngr_msg,
  input  logic                                      from_mngr_val,
  output logic                                      from_mngr_rdy,

  // To mngr streaming port

  output logic [`LAB2_PROC_TO_MNGR_MSG_NBITS-1:0]   to_mngr_msg,
  output logic                                      to_mngr_val,
  input  logic                                      to_mngr_rdy

);

  //----------------------------------------------------------------------
  // Memory
  //----------------------------------------------------------------------

  // Size of data entry in bytes

  localparam c_data_byte_nbits = (p_data_nbits/8);

  // Number of data entries in memory

  localparam c_num_blocks = p_mem_nbytes/c_data_byte_nbits;

  // Actual memory array

  logic [p_data_nbits-1:0] M[c_num_blocks-1:0];

  //----------------------------------------------------------------------
  // Register File
  //----------------------------------------------------------------------

  logic [p_data_nbits-1:0] R[31:0];

  //----------------------------------------------------------------------
  // PC reg
  //----------------------------------------------------------------------

  // Reset vector for the architecture

  localparam c_reset_vector = 32'h1000;

  logic [p_addr_nbits-1:0] PC;
  logic [p_addr_nbits-1:0] PC_next;

  //----------------------------------------------------------------------
  // Instruction Field Unpacking
  //----------------------------------------------------------------------

  logic [31:0] inst;
  logic [31:0] inst_next;

  logic [4:0]  rs;
  logic [4:0]  rt;
  logic [4:0]  rd;
  logic [4:0]  shamt;
  logic [15:0] imm;
  logic [25:0] jtarg;

  logic [31:0] imm_sext;
  logic [31:0] imm_zext;

  //----------------------------------------------------------------------
  // Val/Rdy Ports
  //----------------------------------------------------------------------

  // Specially deal with signals that interface with the outside.
  // We are ready to receive a message from the manager (src) if we are
  // executing a mfc0 instruction. Similarly, we are ready to send
  // a message to the manager (sink) if we are executing a sink
  // instruction. The message we send is R[ rt ].

  always @( * ) begin

    casez( inst )
      `PISA_INST_MFC0 : from_mngr_rdy = !reset;
      default         : from_mngr_rdy = 1'b0;
    endcase

    casez( inst )
      `PISA_INST_MTC0 : to_mngr_val = !reset;
      default         : to_mngr_val = 1'b0;
    endcase

  end

  assign to_mngr_msg   =
    (inst[`PISA_INST_RT] == 5'd0) ? 32'b0
                                  : R[ inst[`PISA_INST_RT] ];

  //----------------------------------------------------------------------
  // Stall
  //----------------------------------------------------------------------

  // Stall if we are ready to receive a message from the manager (src)
  // (i.e., we are executing a mfc0) and the manager does not have a
  // message ready for us. Similarly, stall if we are ready to send
  // a message to the manager (sink) (i.e., we are executing a mtc0) and
  // the manager is not ready to accept a message. Without the stall
  // signal, the mfc0/mtc0 would disappear without doing anything.

  logic stall;

  assign stall = ( !from_mngr_val &&  from_mngr_rdy )
              || (  to_mngr_val   && !to_mngr_rdy   );

  //----------------------------------------------------------------------
  // Instruction Dispatch Table
  //----------------------------------------------------------------------

  // On each cycle, run the instruction's execution task from the
  // dispatch table. A basic_inst() task sets general settings (e.g.,
  // PC_next = PC + 4), and then specific instructions can override
  // these settings according to their semantics. This cleans up the
  // code a lot.

  always @( posedge clk ) begin

    if (reset) begin
      PC            <= c_reset_vector;
      inst          <= M[c_reset_vector >> 2];
    end
    else begin

      // Unpack instruction

      rs       = inst[`PISA_INST_RS];
      rt       = inst[`PISA_INST_RT];
      rd       = inst[`PISA_INST_RD];
      shamt    = inst[`PISA_INST_SHAMT];
      imm      = inst[`PISA_INST_IMM];
      jtarg    = inst[`PISA_INST_TARGET];

      // Calculate sign/zero extended immediate

      imm_sext = { {16{imm[15]}}, imm };
      imm_zext = { {16{1'b0}},    imm };

      // Make sure any reads to R0 gets a zero.

      R[ 5'd0 ] = 32'b0;

      // Basic settings every instruction defaults to

      basic_inst();

      // Dispatch instruction

      casez ( inst )

        `PISA_INST_NOP     : exec_nop();

        `PISA_INST_ADDIU   : exec_addiu();
        `PISA_INST_SLTI    : exec_slti();
        `PISA_INST_SLTIU   : exec_sltiu();
        `PISA_INST_ORI     : exec_ori();
        `PISA_INST_ANDI    : exec_andi();
        `PISA_INST_XORI    : exec_xori();
        `PISA_INST_SRA     : exec_sra();
        `PISA_INST_SRL     : exec_srl();
        `PISA_INST_SLL     : exec_sll();
        `PISA_INST_LUI     : exec_lui();

        `PISA_INST_ADDU    : exec_addu();
        `PISA_INST_SUBU    : exec_subu();
        `PISA_INST_SLT     : exec_slt();
        `PISA_INST_SLTU    : exec_sltu();
        `PISA_INST_AND     : exec_and();
        `PISA_INST_OR      : exec_or();
        `PISA_INST_NOR     : exec_nor();
        `PISA_INST_XOR     : exec_xor();
        `PISA_INST_SRAV    : exec_srav();
        `PISA_INST_SRLV    : exec_srlv();
        `PISA_INST_SLLV    : exec_sllv();

        `PISA_INST_MUL     : exec_mul();

        `PISA_INST_BNE     : exec_bne();
        `PISA_INST_BEQ     : exec_beq();
        `PISA_INST_BGEZ    : exec_bgez();
        `PISA_INST_BGTZ    : exec_bgtz();
        `PISA_INST_BLEZ    : exec_blez();
        `PISA_INST_BLTZ    : exec_bltz();

        `PISA_INST_J       : exec_j();
        `PISA_INST_JR      : exec_jr();
        `PISA_INST_JAL     : exec_jal();

        `PISA_INST_LW      : exec_lw();
        `PISA_INST_SW      : exec_sw();

        `PISA_INST_MFC0    : exec_mfc0();
        `PISA_INST_MTC0    : exec_mtc0();

        default            : exec_unknown();

      endcase

      // Override writes to R0 to make sure it is always zero
      // Note: We purposely use blocking assignments to the register
      // file so we can override writes to R0 here. This should be safe
      // because this is the only block that touches the register file
      // contents.

      R[ 5'd0 ] = 32'b0;

      // Fetch next instruction

      inst_next = M[PC_next >> 2];

      // Update state

      inst      <= inst_next;
      PC        <= PC_next;

    end
  end

  //----------------------------------------------------------------------
  // Instruction Execution
  //----------------------------------------------------------------------

  // Basic control every instruction defaults to

  task basic_inst;
  begin
    PC_next = PC + 32'd4;
  end
  endtask

  // nop
  task exec_nop;
  begin
    // nop does nothing
  end
  endtask

  // addiu
  task exec_addiu;
  begin
    R[ rt ] = imm_sext + R[ rs ];
  end
  endtask

  // slti
  task exec_slti;
  begin
    R[ rt ] = ( $signed(R[ rs ]) < $signed(imm_sext) );
  end
  endtask

  // sltiu
  task exec_sltiu;
  begin
    R[ rt ] = ( R[ rs ] < imm_sext );
  end
  endtask

  // ori
  task exec_ori;
  begin
    R[ rt ] = R[ rs ] | imm_zext;
  end
  endtask

  // andi
  task exec_andi;
  begin
    R[ rt ] = R[ rs ] & imm_zext;
  end
  endtask

  // xori
  task exec_xori;
  begin
    R[ rt ] = R[ rs ] ^ imm_zext;
  end
  endtask

  // sra
  task exec_sra;
  begin
    R[ rd ] = $signed(R[ rt ]) >>> shamt;
  end
  endtask

  // srl
  task exec_srl;
  begin
    R[ rd ] = R[ rt ] >> shamt;
  end
  endtask

  // sll
  task exec_sll;
  begin
    R[ rd ] = R[ rt ] << shamt;
  end
  endtask

  // lui
  task exec_lui;
  begin
    R[ rt ] = imm << 16;
  end
  endtask

  // addu
  task exec_addu;
  begin
    R[ rd ] = R[ rs ] + R[ rt ];
  end
  endtask

  // subu
  task exec_subu;
  begin
    R[ rd ] = R[ rs ] - R[ rt ];
  end
  endtask

  // slt
  task exec_slt;
  begin
    R[ rd ] = ( $signed(R[ rs ]) < $signed(R[ rt ]) );
  end
  endtask

  // sltu
  task exec_sltu;
  begin
    R[ rd ] = ( R[ rs ] < R[ rt ] );
  end
  endtask

  // and
  task exec_and;
  begin
    R[ rd ] = R[ rs ] & R[ rt ];
  end
  endtask

  // or
  task exec_or;
  begin
    R[ rd ] = R[ rs ] | R[ rt ];
  end
  endtask

  // nor
  task exec_nor;
  begin
    R[ rd ] = ~(R[ rs ] | R[ rt ]);
  end
  endtask

  // xor
  task exec_xor;
  begin
    R[ rd ] = R[ rs ] ^ R[ rt ];
  end
  endtask

  // srav
  task exec_srav;
  begin
    R[ rd ] = $signed(R[ rt ]) >>> R[ rs ][4:0];
  end
  endtask

  // srlv
  task exec_srlv;
  begin
    R[ rd ] = R[ rt ] >> R[ rs ][4:0];
  end
  endtask

  // sllv
  task exec_sllv;
  begin
    R[ rd ] = R[ rt ] << R[ rs ][4:0];
  end
  endtask

  // mul
  task exec_mul;
  begin
    R[ rd ] = R[ rs ] * R[ rt ];
  end
  endtask

  // bne
  task exec_bne;
  begin
    if (R[ rs ] != R[ rt ])
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // beq
  task exec_beq;
  begin
    if (R[ rs ] == R[ rt ])
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // bgez
  task exec_bgez;
  begin
    if ($signed(R[ rs ]) >= $signed(32'b0))
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // bgtz
  task exec_bgtz;
  begin
    if ($signed(R[ rs ]) > $signed(32'b0))
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // blez
  task exec_blez;
  begin
    if ($signed(R[ rs ]) <= $signed(32'b0))
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // bltz
  task exec_bltz;
  begin
    if ($signed(R[ rs ]) < $signed(32'b0))
      PC_next = PC + 32'd4 + (imm_sext << 2);
  end
  endtask

  // j
  task exec_j;
  begin
    PC_next = { PC[31:28], jtarg << 2 };
  end
  endtask

  // jr
  task exec_jr;
  begin
    PC_next = R[ rs ];
  end
  endtask

  // jal
  task exec_jal;
  begin
    PC_next = { PC[31:28], jtarg << 2 };
    R[ 5'd31 ] = PC + 32'd4;
  end
  endtask

  // lw
  task exec_lw;
  begin
    R[ rt ] = M[ (R[ rs ] + imm_sext) >> 2 ];
  end
  endtask

  // sw
  task exec_sw;
  begin
    M[ (R[ rs ] + imm_sext) >> 2 ] = R[ rt ];
  end
  endtask

  // mfc0
  task exec_mfc0;
  begin
    if (stall) begin
      PC_next = PC;
    end
    else begin
      R[ rt ] = from_mngr_msg;
    end
  end
  endtask

  // mtc0
  task exec_mtc0;
  begin
    if (stall) begin
      PC_next = PC;
    end
  end
  endtask

  // unknown
  task exec_unknown;
  begin
    $display("Encountered unknown instruction! (Inst: 0x%h, PC: 0x%h)", inst, PC);
    $finish();
  end
  endtask

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  pisa_InstTasks pisa();

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    if (stall) begin
      $sformat( str, "       # :   #                     " );
    end
    else begin
      $sformat( str, "%x : %s", PC, pisa.disasm(inst) );
    end

    vc_trace.append_str( trace_str, str );

  end
  `VC_TRACE_END

endmodule

`endif

