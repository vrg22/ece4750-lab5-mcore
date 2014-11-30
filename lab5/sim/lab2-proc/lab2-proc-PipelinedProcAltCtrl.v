//=========================================================================
// 5-Stage Bypass Pipelined Processor Control
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_ALT_CTRL_V
`define LAB2_PROC_PIPELINED_PROC_ALT_CTRL_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "vc-PipeCtrl.v"
`include "vc-mem-msgs.v"
`include "vc-assert.v"
`include "pisa-inst.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

module lab2_proc_PipelinedProcAltCtrl
(
  input  logic        clk,
//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
//   input  logic        reset
//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++
//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  input  logic        reset,

  // Instruction Memory Port

  output logic        imemreq_val,
  input  logic        imemreq_rdy,

  input  logic        imemresp_val,
  output logic        imemresp_rdy,

  output logic        imemresp_drop,

  // Data Memory Port

  output logic                                           dmemreq_val,
  input  logic                                           dmemreq_rdy,
  output logic [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0] dmemreq_msg_type,

  input  logic                                           dmemresp_val,
  output logic                                           dmemresp_rdy,

  // mngr communication port

  input  logic        from_mngr_val,
  output logic        from_mngr_rdy,

  output logic        to_mngr_val,
  input logic         to_mngr_rdy,

  // mul unit ports (control and status)

  output logic        mul_req_val_D,
  input  logic        mul_req_rdy_D,

  input  logic        mul_resp_val_X,
  output logic        mul_resp_rdy_X,

  // control signals (ctrl->dpath)

  output logic [1:0]  pc_sel_F,
  output logic        reg_en_F,
  output logic        reg_en_D,
  output logic        reg_en_X,
  output logic        reg_en_M,
  output logic        reg_en_W,
  output logic [1:0]  op0_sel_D,
  output logic [2:0]  op1_sel_D,
  output logic [1:0]  op0_byp_sel_D,
  output logic [1:0]  op1_byp_sel_D,
  output logic [1:0]  mfc_sel_D,
  output logic [3:0]  alu_fn_X,
  output logic        ex_result_sel_X,
  output logic        wb_result_sel_M,
  output logic [4:0]  rf_waddr_W,
  output logic        rf_wen_W,
  output logic        stats_en_wen_W,

  // status signals (dpath->ctrl)

  input logic [31:0]  inst_D,
  input logic         br_cond_zero_X,
  input logic         br_cond_neg_X,
  input logic         br_cond_eq_X
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

);

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // copy in the baseline design and start working on the alternative!
//
// // temporary dummy signal
//
// logic val_MW;
//
//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
  //----------------------------------------------------------------------
  // F stage
  //----------------------------------------------------------------------

  logic val_F;
  logic stall_F;
  logic squash_F;

  logic val_FD;
  logic stall_FD;
  logic squash_FD;

  logic stall_PF;
  logic squash_PF;

  vc_PipeCtrl pipe_ctrl_F
  (
    .clk         ( clk       ),
    .reset       ( reset     ),

    .prev_val    ( 1'b1      ),
    .prev_stall  ( stall_PF  ),
    .prev_squash ( squash_PF ),

    .curr_reg_en ( reg_en_F  ),
    .curr_val    ( val_F     ),
    .curr_stall  ( stall_F   ),
    .curr_squash ( squash_F  ),

    .next_val    ( val_FD    ),
    .next_stall  ( stall_FD  ),
    .next_squash ( squash_FD )
  );

  // PC Mux select

  localparam pm_x     = 2'dx; // Don't care
  localparam pm_p     = 2'd0; // Use pc+4
  localparam pm_b     = 2'd1; // Use branch address
  localparam pm_j     = 2'd2; // Use jump address (imm)
  localparam pm_r     = 2'd3; // Use jump address (reg)

  logic [1:0] j_pc_sel_D;
  logic       j_taken_D;
  logic       br_taken_X;

  assign pc_sel_F = ( br_taken_X ? pm_b       :
                    ( j_taken_D  ? j_pc_sel_D :
                                   pm_p       ) );

  logic stall_imem_F;

  assign imemreq_val = !stall_PF;

  assign imemresp_rdy = !stall_FD;
  assign stall_imem_F = !imemresp_val && !imemresp_drop;

  // we drop the mem response when we are getting squashed

  assign imemresp_drop = squash_FD && !stall_FD;

  assign stall_F = stall_imem_F;
  assign squash_F = 1'b0;


  //----------------------------------------------------------------------
  // D stage
  //----------------------------------------------------------------------

  logic val_D;
  logic stall_D;
  logic squash_D;

  logic val_DX;
  logic stall_DX;
  logic squash_DX;

  vc_PipeCtrl pipe_ctrl_D
  (
    .clk         ( clk       ),
    .reset       ( reset     ),

    .prev_val    ( val_FD    ),
    .prev_stall  ( stall_FD  ),
    .prev_squash ( squash_FD ),

    .curr_reg_en ( reg_en_D  ),
    .curr_val    ( val_D     ),
    .curr_stall  ( stall_D   ),
    .curr_squash ( squash_D  ),

    .next_val    ( val_DX    ),
    .next_stall  ( stall_DX  ),
    .next_squash ( squash_DX )
  );

  // decode logic

  // Parse instruction fields

  logic   [4:0] inst_rs_D;
  logic   [4:0] inst_rt_D;
  logic   [4:0] inst_rd_D;

  pisa_InstUnpack inst_unpack
  (
    .inst     (inst_D),
    .opcode   (),
    .rs       (inst_rs_D),
    .rt       (inst_rt_D),
    .rd       (inst_rd_D),
    .shamt    (),
    .func     (),
    .imm      (),
    .target   ()
  );

  // Shorten register specifier name for table

  logic [4:0] rs;
  assign rs = inst_rs_D;
  logic [4:0] rt;
  assign rt = inst_rt_D;
  logic [4:0] rd;
  assign rd = inst_rd_D;

  // Generic Parameters

  localparam n = 1'd0;
  localparam y = 1'd1;

  // Register specifiers

  localparam rx = 5'bx;
  localparam r0 = 5'd0;
  localparam rL = 5'd31;

  // Branch type

  localparam br_x     = 3'dx; // Don't care
  localparam br_none  = 3'd0; // No branch
  localparam br_bne   = 3'd1; // bne
  localparam br_beq   = 3'd2; // beq
  localparam br_bgez  = 3'd3; // bgez
  localparam br_bgtz  = 3'd4; // bgtz
  localparam br_blez  = 3'd5; // blez
  localparam br_bltz  = 3'd6; // bltz

  // Jump type

  localparam j_x = 2'dx; // Don't care
  localparam j_n = 2'd0; // No jump
  localparam j_j = 2'd1; // jump (imm)
  localparam j_r = 2'd2; // jump (reg)

  // Operand 0 Mux Select

  localparam am_x     = 2'bx; // Don't care
  localparam am_rdat  = 2'd0; // Use data from register file
  localparam am_samt  = 2'd1; // Use shift amount from immediate
  localparam am_16    = 2'd2; // Use constant 16 (for lui)

  // Operand 1 Mux Select

  localparam bm_x     = 3'bx; // Don't care
  localparam bm_rdat  = 3'd0; // Use data from register file
  localparam bm_si    = 3'd1; // Use sign-extended immediate
  localparam bm_zi    = 3'd2; // Use zero-extended immediate
  localparam bm_pc    = 3'd3; // Use PC+4
  localparam bm_fhst  = 3'd4; // Use from mngr data

  // Bypass path Mux select

  localparam byp_r    = 2'd0; // Use regfile
  localparam byp_x    = 2'd1; // Bypass from X stage
  localparam byp_m    = 2'd2; // Bypass from X stage
  localparam byp_w    = 2'd3; // Bypass from X stage

  // ALU Function

  localparam alu_x    = 4'bx;
  localparam alu_add  = 4'd0;
  localparam alu_sub  = 4'd1;
  localparam alu_sll  = 4'd2;
  localparam alu_or   = 4'd3;
  localparam alu_lt   = 4'd4;
  localparam alu_ltu  = 4'd5;
  localparam alu_and  = 4'd6;
  localparam alu_xor  = 4'd7;
  localparam alu_nor  = 4'd8;
  localparam alu_srl  = 4'd9;
  localparam alu_sra  = 4'd10;
  localparam alu_cp0  = 4'd11;
  localparam alu_cp1  = 4'd12;

  // Memory Request Type

  localparam nr       = 3'd0; // No request
  localparam ld       = 3'd1; // Load
  localparam st       = 3'd2; // Store
  localparam ad       = 3'd3; // amo.add
  localparam an       = 3'd4; // amo.add
  localparam ao       = 3'd5; // amo.add

  // Multiply Request Type

  localparam mul_n    = 1'd0; // No multiply
  localparam mul_m    = 1'd1; // Multiply

  // Execute Mux Select

  localparam xm_x     = 1'bx; // Don't care
  localparam xm_a     = 1'b0; // Use ALU output
  localparam xm_m     = 1'b1; // Use mul unit reponse

  // Writeback Mux Select

  localparam wm_x     = 1'bx; // Don't care
  localparam wm_a     = 1'b0; // Use ALU output
  localparam wm_m     = 1'b1; // Use data memory response

  // Instruction Decode

  logic       inst_val_D;
  logic [1:0] j_type_D;
  logic [2:0] br_type_D;
  logic       rs_en_D;
  logic       rt_en_D;
  logic [3:0] alu_fn_D;
  logic       mul_req_type_D;
  logic       ex_result_sel_D;
  logic [2:0] dmemreq_type_D;
  logic       wb_result_sel_D;
  logic       rf_wen_D;
  logic [4:0] rf_waddr_D;
  logic       mtc_D;
  logic       mfc_D;

  task cs
  (
    input logic       cs_val,
    input logic [1:0] cs_j_type,
    input logic [2:0] cs_br_type,
    input logic [1:0] cs_op0_sel,
    input logic       cs_rs_en,
    input logic [2:0] cs_op1_sel,
    input logic       cs_rt_en,
    input logic [3:0] cs_alu_fn,
    input logic       cs_mul_req_type,
    input logic       cs_ex_result_sel,
    input logic [2:0] cs_dmemreq_type,
    input logic       cs_wb_result_sel,
    input logic       cs_rf_wen,
    input logic [4:0] cs_rf_waddr,
    input logic       cs_mtc,
    input logic       cs_mfc
  );
  begin
    inst_val_D       = cs_val;
    j_type_D         = cs_j_type;
    br_type_D        = cs_br_type;
    op0_sel_D        = cs_op0_sel;
    rs_en_D          = cs_rs_en;
    op1_sel_D        = cs_op1_sel;
    rt_en_D          = cs_rt_en;
    alu_fn_D         = cs_alu_fn;
    mul_req_type_D   = cs_mul_req_type;
    ex_result_sel_D  = cs_ex_result_sel;
    dmemreq_type_D   = cs_dmemreq_type;
    wb_result_sel_D  = cs_wb_result_sel;
    rf_wen_D         = cs_rf_wen;
    rf_waddr_D       = cs_rf_waddr;
    mtc_D            = cs_mtc;
    mfc_D            = cs_mfc;
  end
  endtask


  always @ (*) begin

    casez ( inst_D )

      //                          j    br       op0      rs op1      rt alu      mul    xmux  dmm wbmux rf
      //                      val type type     muxsel   en muxsel   en fn       type   sel   typ sel   wen wa  mtc  mfc
      `PISA_INST_NOP     :cs( y,  j_n, br_none, am_x,    n, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );

      `PISA_INST_ADDIU   :cs( y,  j_n, br_none, am_rdat, y, bm_si,   n, alu_add, mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_SLTI    :cs( y,  j_n, br_none, am_rdat, y, bm_si,   n, alu_lt,  mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_SLTIU   :cs( y,  j_n, br_none, am_rdat, y, bm_si,   n, alu_ltu, mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_ORI     :cs( y,  j_n, br_none, am_rdat, y, bm_zi,   n, alu_or,  mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_ANDI    :cs( y,  j_n, br_none, am_rdat, y, bm_zi,   n, alu_and, mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_XORI    :cs( y,  j_n, br_none, am_rdat, y, bm_zi,   n, alu_xor, mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_SRA     :cs( y,  j_n, br_none, am_samt, n, bm_rdat, y, alu_sra, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRL     :cs( y,  j_n, br_none, am_samt, n, bm_rdat, y, alu_srl, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLL     :cs( y,  j_n, br_none, am_samt, n, bm_rdat, y, alu_sll, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_LUI     :cs( y,  j_n, br_none, am_16,   y, bm_si,   y, alu_sll, mul_n, xm_a, nr, wm_a, y,  rt, n,   n   );

      `PISA_INST_ADDU    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_add, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SUBU    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_sub, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLT     :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_lt,  mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLTU    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_ltu, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_AND     :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_and, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_OR      :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_or,  mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_NOR     :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_nor, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_XOR     :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_xor, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRAV    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_sra, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRLV    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_srl, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLLV    :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_sll, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );

      `PISA_INST_MUL     :cs( y,  j_n, br_none, am_rdat, y, bm_rdat, y, alu_x,   mul_m, xm_m, nr, wm_a, y,  rd, n,   n   );

      `PISA_INST_BNE     :cs( y,  j_n, br_bne,  am_rdat, y, bm_rdat, y, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_BEQ     :cs( y,  j_n, br_beq,  am_rdat, y, bm_rdat, y, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_BGEZ    :cs( y,  j_n, br_bgez, am_rdat, y, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_BGTZ    :cs( y,  j_n, br_bgtz, am_rdat, y, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_BLEZ    :cs( y,  j_n, br_blez, am_rdat, y, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_BLTZ    :cs( y,  j_n, br_bltz, am_rdat, y, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );

      `PISA_INST_J       :cs( y,  j_j, br_none, am_x,    n, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_JR      :cs( y,  j_r, br_none, am_x,    y, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_JALR    :cs( y,  j_r, br_none, am_x,    y, bm_pc,   n, alu_cp1, mul_n, xm_a, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_JAL     :cs( y,  j_j, br_none, am_x,    n, bm_pc,   n, alu_cp1, mul_n, xm_a, nr, wm_a, y,  rL, n,   n   );

      `PISA_INST_LW      :cs( y,  j_n, br_none, am_rdat, y, bm_si,   n, alu_add, mul_n, xm_a, ld, wm_m, y,  rt, n,   n   );
      `PISA_INST_SW      :cs( y,  j_n, br_none, am_rdat, y, bm_si,   y, alu_add, mul_n, xm_a, st, wm_x, n,  rx, n,   n   );

      `PISA_INST_MFC0    :cs( y,  j_n, br_none, am_x,    n, bm_fhst, n, alu_cp1, mul_n, xm_a, nr, wm_a, y,  rt, n,   y   );
      `PISA_INST_MTC0    :cs( y,  j_n, br_none, am_x,    n, bm_rdat, y, alu_cp1, mul_n, xm_a, nr, wm_a, n,  rx, y,   n   );

      `PISA_INST_AMO_ADD :cs( y,  j_n, br_none, am_rdat, y, bm_x,    y, alu_cp0, mul_n, xm_a, ad, wm_m, y,  rd, n,   n   );
      `PISA_INST_AMO_AND :cs( y,  j_n, br_none, am_rdat, y, bm_x,    y, alu_cp0, mul_n, xm_a, an, wm_m, y,  rd, n,   n   );
      `PISA_INST_AMO_OR  :cs( y,  j_n, br_none, am_rdat, y, bm_x,    y, alu_cp0, mul_n, xm_a, ao, wm_m, y,  rd, n,   n   );

      default            :cs( n,  j_x, br_x,    am_x,    n, bm_x,    n, alu_x,   mul_n, xm_x, nr, wm_x, n,  rx, n,   n   );

    endcase
  end

  logic stall_from_mngr_D;
  logic stall_mul_req_D;
  logic stall_hazard_D;

  // jump logic

  logic      squash_j_D;
  logic      stall_j_D;

  always @(*) begin
    if ( val_D ) begin

      case ( j_type_D )
        j_j:     j_pc_sel_D = pm_j;
        j_r:     j_pc_sel_D = pm_r;
        default: j_pc_sel_D = pm_p;
      endcase

    end else
      j_pc_sel_D = pm_p;
  end

  assign j_taken_D = ( j_pc_sel_D != pm_p );

  assign squash_j_D = j_taken_D;

  // mtc and mfc instructions

  logic to_mngr_val_D;
  logic from_mngr_rdy_D;
  logic stats_en_wen_D;

  always @(*) begin
    to_mngr_val_D    = 1'b0;
    from_mngr_rdy_D  = 1'b0;
    stats_en_wen_D   = 1'b0;
    mfc_sel_D        = 2'h0;
    if ( mtc_D && rd == `PISA_CPR_PROC2MNGR )
      to_mngr_val_D    = 1'b1;
    if ( mtc_D && rd == `PISA_CPR_STATS_EN )
      stats_en_wen_D    = 1'b1;
    if ( mfc_D && rd == `PISA_CPR_MNGR2PROC )
      from_mngr_rdy_D  = 1'b1;
    if ( mfc_D && rd == `PISA_CPR_NUMCORES )
      mfc_sel_D        = 2'h1;
    if ( mfc_D && rd == `PISA_CPR_COREID )
      mfc_sel_D        = 2'h2;

  end

  // Bypassing logic

  always @(*) begin

    if      ( rs_en_D && val_X && rf_wen_X
         && ( inst_rs_D == rf_waddr_X )
         && ( rf_waddr_X != 5'd0 ) )
      op0_byp_sel_D = byp_x;
    else if ( rs_en_D && val_M && rf_wen_M
         && ( inst_rs_D == rf_waddr_M )
         && ( rf_waddr_M != 5'd0 ) )
      op0_byp_sel_D = byp_m;
    else if ( rs_en_D && val_W && rf_wen_W
         && ( inst_rs_D == rf_waddr_W )
         && ( rf_waddr_W != 5'd0 ) )
      op0_byp_sel_D = byp_w;
    else
      op0_byp_sel_D = byp_r;

    if      ( rt_en_D && val_X && rf_wen_X
         && ( inst_rt_D == rf_waddr_X )
         && ( rf_waddr_X != 5'd0 ) )
      op1_byp_sel_D = byp_x;
    else if ( rt_en_D && val_M && rf_wen_M
         && ( inst_rt_D == rf_waddr_M )
         && ( rf_waddr_M != 5'd0 ) )
      op1_byp_sel_D = byp_m;
    else if ( rt_en_D && val_W && rf_wen_W
         && ( inst_rt_D == rf_waddr_W )
         && ( rf_waddr_W != 5'd0 ) )
      op1_byp_sel_D = byp_w;
    else
      op1_byp_sel_D = byp_r;

  end

  // from mngr rdy signal for mfc0 instruction

  assign from_mngr_rdy     = ( val_D && from_mngr_rdy_D && !stall_FD );
  assign stall_from_mngr_D = ( val_D && from_mngr_rdy_D && !from_mngr_val );

  // multiplier signals

  assign mul_req_val_D   = ( val_D && ( mul_req_type_D != mul_n )
                             && !stall_FD && !squash_DX );

  assign stall_mul_req_D = ( val_D && ( mul_req_type_D != mul_n )
                             && !mul_req_rdy_D );

  // Stall if load address in X matches rs in D

  logic stall_load_use_X_rs_D;
  assign stall_load_use_X_rs_D
    = ( rs_en_D && val_X && rf_wen_X
        && ( inst_rs_D == rf_waddr_X ) && ( rf_waddr_X != 5'd0 )
        && ( dmemreq_type_X != nr ) && ( dmemreq_type_X != st ) );

  // Stall if load address in M matches rs in D, and the load in M is stalling

  logic stall_load_use_M_rs_D;
  assign stall_load_use_M_rs_D
    = ( rs_en_D && val_M && rf_wen_M
        && ( inst_rs_D == rf_waddr_M ) && ( rf_waddr_M != 5'd0 )
        && ( dmemreq_type_M != nr ) && ( dmemreq_type_M != st ) && stall_dmem_M );

  // Stall if load address in X matches rt in D

  logic stall_load_use_X_rt_D;
  assign stall_load_use_X_rt_D
    = ( rt_en_D && val_X && rf_wen_X
        && ( inst_rt_D == rf_waddr_X ) && ( rf_waddr_X != 5'd0 )
        && ( dmemreq_type_X != nr ) && ( dmemreq_type_X != st ) );

  // Stall if load address in M matches rt in D, and the load in M is stalling

  logic stall_load_use_M_rt_D;
  assign stall_load_use_M_rt_D
    = ( rt_en_D && val_M && rf_wen_M
        && ( inst_rt_D == rf_waddr_M ) && ( rf_waddr_M != 5'd0 )
        && ( dmemreq_type_M != nr ) && ( dmemreq_type_M != st ) && stall_dmem_M );

  // Put together final stall signal

  assign stall_hazard_D = val_D &&
    ( stall_load_use_X_rs_D || stall_load_use_M_rs_D ||
      stall_load_use_X_rt_D || stall_load_use_M_rt_D );

  //// we assert that the instruction is decoded properly (if it doesn't it
  //// might be due to it not being implemented)
  //always @( posedge clk ) begin
  //  if ( !reset ) begin
  //    `VC_ASSERT( inst_val_D );
  //  end
  //end

  assign stall_D = stall_from_mngr_D || stall_hazard_D || stall_mul_req_D;
  assign squash_D = squash_j_D;

  //----------------------------------------------------------------------
  // X stage
  //----------------------------------------------------------------------

  logic val_X;
  logic stall_X;
  logic squash_X;

  logic val_XM;
  logic stall_XM;
  logic squash_XM;

  vc_PipeCtrl pipe_ctrl_X
  (
    .clk         ( clk       ),
    .reset       ( reset     ),

    .prev_val    ( val_DX    ),
    .prev_stall  ( stall_DX  ),
    .prev_squash ( squash_DX ),

    .curr_reg_en ( reg_en_X  ),
    .curr_val    ( val_X     ),
    .curr_stall  ( stall_X   ),
    .curr_squash ( squash_X  ),

    .next_val    ( val_XM    ),
    .next_stall  ( stall_XM  ),
    .next_squash ( squash_XM )
  );

  logic [31:0] inst_X;
  logic        mul_req_type_X;
  logic [2:0]  dmemreq_type_X;
  logic        wb_result_sel_X;
  logic        rf_wen_X;
  logic [4:0]  rf_waddr_X;
  logic        to_mngr_val_X;
  logic        stats_en_wen_X;
  logic [2:0]  br_type_X;

  always @(posedge clk) begin
    if (reset) begin
      rf_wen_X        <= 1'b0;
      stats_en_wen_X  <= 1'b0;
    end else if (reg_en_X) begin
      inst_X          <= inst_D;
      alu_fn_X        <= alu_fn_D;
      dmemreq_type_X  <= dmemreq_type_D;
      mul_req_type_X  <= mul_req_type_D;
      ex_result_sel_X <= ex_result_sel_D;
      wb_result_sel_X <= wb_result_sel_D;
      rf_wen_X        <= rf_wen_D;
      rf_waddr_X      <= rf_waddr_D;
      to_mngr_val_X   <= to_mngr_val_D;
      stats_en_wen_X  <= stats_en_wen_D;
      br_type_X       <= br_type_D;
    end
  end

  // branch logic

  logic        squash_br_X;
  logic        stall_br_X;

  always @(*) begin
    if ( val_X ) begin

      case ( br_type_X )
        br_bne :  br_taken_X = !br_cond_eq_X;
        br_beq :  br_taken_X =  br_cond_eq_X;
        br_bgez:  br_taken_X = !br_cond_neg_X ||  br_cond_zero_X;
        br_bgtz:  br_taken_X = !br_cond_neg_X && !br_cond_zero_X;
        br_blez:  br_taken_X =  br_cond_neg_X ||  br_cond_zero_X;
        br_bltz:  br_taken_X =  br_cond_neg_X && !br_cond_zero_X;
        default:  br_taken_X = 1'b0;
      endcase

    end else
      br_taken_X = 1'b0;
  end

  // squash the previous instructions on branch

  assign squash_br_X = br_taken_X;

  logic dmemreq_val_X;
  logic stall_dmem_X;

  // dmem logic

  assign dmemreq_val_X = val_X && ( dmemreq_type_X != nr );

  assign dmemreq_val  = dmemreq_val_X && !stall_XM;
  assign stall_dmem_X = dmemreq_val_X && !dmemreq_rdy;

  always @(*) begin
    case ( dmemreq_type_X )
      ld: dmemreq_msg_type = `VC_MEM_REQ_MSG_TYPE_READ;
      st: dmemreq_msg_type = `VC_MEM_REQ_MSG_TYPE_WRITE;
      ad: dmemreq_msg_type = `VC_MEM_REQ_MSG_TYPE_AMO_ADD;
      an: dmemreq_msg_type = `VC_MEM_REQ_MSG_TYPE_AMO_AND;
      ao: dmemreq_msg_type = `VC_MEM_REQ_MSG_TYPE_AMO_OR;
      default: dmemreq_msg_type = 'hx;
    endcase
  end

  // mul logic

  logic stall_mul_resp_X;

  assign mul_resp_rdy_X =    ( val_X
                            && ( mul_req_type_X != mul_n )
                            && !stall_DX );

  assign stall_mul_resp_X  = ( val_X
                            && ( mul_req_type_X != mul_n )
                            && !mul_resp_val_X );

  // stall in X if dmem is not rdy

  assign stall_X = stall_dmem_X || stall_mul_resp_X;
  assign squash_X = squash_br_X;

  //----------------------------------------------------------------------
  // M stage
  //----------------------------------------------------------------------

  logic val_M;
  logic stall_M;
  logic squash_M;

  logic val_MW;
  logic stall_MW;
  logic squash_MW;

  vc_PipeCtrl pipe_ctrl_M
  (
    .clk         ( clk       ),
    .reset       ( reset     ),

    .prev_val    ( val_XM    ),
    .prev_stall  ( stall_XM  ),
    .prev_squash ( squash_XM ),

    .curr_reg_en ( reg_en_M  ),
    .curr_val    ( val_M     ),
    .curr_stall  ( stall_M   ),
    .curr_squash ( squash_M  ),

    .next_val    ( val_MW    ),
    .next_stall  ( stall_MW  ),
    .next_squash ( squash_MW )
  );

  logic [31:0] inst_M;
  logic [2:0]  dmemreq_type_M;
  logic        rf_wen_M;
  logic [4:0]  rf_waddr_M;
  logic        stats_en_wen_M;
  logic        to_mngr_val_M;

  always @(posedge clk) begin
    if (reset) begin
      rf_wen_M        <= 1'b0;
      stats_en_wen_M  <= 1'b0;
    end else if (reg_en_M) begin
      inst_M          <= inst_X;
      dmemreq_type_M  <= dmemreq_type_X;
      wb_result_sel_M <= wb_result_sel_X;
      rf_wen_M        <= rf_wen_X;
      rf_waddr_M      <= rf_waddr_X;
      stats_en_wen_M  <= stats_en_wen_X;
      to_mngr_val_M   <= to_mngr_val_X;
    end
  end

  logic dmemreq_val_M;
  logic stall_dmem_M;

  assign dmemresp_rdy = dmemreq_val_M && !stall_MW;

  assign dmemreq_val_M = val_M && ( dmemreq_type_M != nr );
  assign stall_dmem_M = ( dmemreq_val_M && !dmemresp_val );

  assign stall_M = stall_dmem_M;
  assign squash_M = 1'b0;

  //----------------------------------------------------------------------
  // W stage
  //----------------------------------------------------------------------

  logic val_W;
  logic stall_W;
  logic squash_W;

  logic next_stall_W;
  logic next_squash_W;

  assign next_stall_W = 1'b0;
  assign next_squash_W = 1'b0;

  vc_PipeCtrl pipe_ctrl_W
  (
    .clk         ( clk       ),
    .reset       ( reset     ),

    .prev_val    ( val_MW    ),
    .prev_stall  ( stall_MW  ),
    .prev_squash ( squash_MW ),

    .curr_reg_en ( reg_en_W  ),
    .curr_val    ( val_W     ),
    .curr_stall  ( stall_W   ),
    .curr_squash ( squash_W  ),

    .next_stall  ( next_stall_W  ),
    .next_squash ( next_squash_W )
  );

  logic [31:0] inst_W;
  logic        to_mngr_val_W;
  logic        stall_to_mngr_W;

  always @(posedge clk) begin
    if (reset) begin
      rf_wen_W      <= 1'b0;
      stats_en_wen_W<= 1'b0;
    end else if (reg_en_W) begin
      inst_W        <= inst_M;
      rf_wen_W      <= rf_wen_M;
      rf_waddr_W    <= rf_waddr_M;
      stats_en_wen_W<= stats_en_wen_M;
      to_mngr_val_W <= to_mngr_val_M;
    end
  end

  assign to_mngr_val     = ( val_W && to_mngr_val_W && !stall_MW );
  assign stall_to_mngr_W = ( val_W && to_mngr_val_W && !to_mngr_rdy );

  assign stall_W = stall_to_mngr_W;
  assign squash_W = 1'b0;

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
endmodule

`endif
