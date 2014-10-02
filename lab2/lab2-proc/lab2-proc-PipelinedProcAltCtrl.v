//=========================================================================
// 5-Stage Bypass Pipelined Processor Control
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_ALT_CTRL_V
`define LAB2_PROC_PIPELINED_PROC_ALT_CTRL_V

`include "vc-PipeCtrl.v"
`include "vc-assert.v"
`include "vc-mem-msgs.v"
`include "pisa-inst.v"

module lab2_proc_PipelinedProcAltCtrl
(
  input  logic        clk,
  input  logic        reset,

  // Instruction Memory Port

  output logic        imemreq_val,
  input  logic        imemreq_rdy,

  input  logic        imemresp_val,
  output logic        imemresp_rdy,

  output logic        imemresp_drop,

  // Data Memory Port

  output logic        dmemreq_val,
  input  logic        dmemreq_rdy,
  output logic [2:0]  dmemreq_type,

  input  logic        dmemresp_val,
  output logic        dmemresp_rdy,

  // Mul Signals

  output logic        mulreq_val,
  input  logic        mulreq_rdy,

  input  logic        mulresp_val,
  output logic        mulresp_rdy,

  // mngr communication port

  input  logic        from_mngr_val,
  output logic        from_mngr_rdy,

  output logic        to_mngr_val,
  input  logic        to_mngr_rdy,

  // control signals (ctrl->dpath)

  output logic [1:0]  pc_sel_F,
  output logic        reg_en_F,
  output logic        reg_en_D,
  output logic        reg_en_X,
  output logic        reg_en_M,
  output logic        reg_en_W,
  output logic [1:0]  op0_sel_D,
  output logic [2:0]  op1_sel_D,
  output logic [3:0]  alu_fn_X,
  output logic        ex_mux_sel_X,
  output logic        wb_result_sel_M,
  output logic [4:0]  rf_waddr_W,
  output logic        rf_wen_W,

  output logic [1:0]  bypass_rs,
  output logic [1:0]  bypass_rt,

  // status signals (dpath->ctrl)

  input  logic[31:0]  inst_D,
  input  logic        br_cond_eq_X,
  input  logic        br_cond_neg_X,
  input  logic        br_cond_zero_X
);

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
  localparam pm_b     = 2'd0; // Use branch address
  localparam pm_r     = 2'd1; // Use register value
  localparam pm_j     = 2'd2; // Use jump address (imm)
  localparam pm_p     = 2'd3; // Use pc+4

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
  logic   [4:0] inst_shamt_D;
  pisa_InstUnpack inst_unpack
  (
    .inst     ( inst_D ),
    .opcode   (),
    .rs       (inst_rs_D),
    .rt       (inst_rt_D),
    .rd       (inst_rd_D),
    .shamt    (inst_shamt_D),
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
  logic [4:0] shamt;
  assign shamt = inst_shamt_D;

  // Generic Parameters

  localparam n = 1'd0;
  localparam y = 1'd1;

  // Register specifiers

  localparam rx = 5'bx;
  localparam r0 = 5'd0;
  localparam rL = 5'd31;

  // Branch type

  localparam br_x     = 3'bx; // Don't care
  localparam br_none  = 3'd0; // No branch
  localparam br_ne    = 3'd1; // bne
  localparam br_eq    = 3'd2; // beq
  localparam br_gtz   = 3'd3; // bgtz
  localparam br_ltz   = 3'd4; // bltz
  localparam br_gez   = 3'd5; // bgez
  localparam br_lez   = 3'd6; // blez

  // Jump type

  localparam j_x      = 2'bx; // Don't care
  localparam j_n      = 2'd0; // No jump
  localparam j_j      = 2'd1; // jump (imm)
  localparam j_r      = 2'd2; // jump (register)
  localparam j_l      = 2'd3; // JAL

  // Operand 0 Mux Select

  localparam am_x     = 2'bx;
  localparam am_shamt = 2'd0;  //use shamt field in instruction
  localparam am_rdat  = 2'd1;  //use register file


  // Operand 1 Mux Select

  localparam bm_x     = 3'bx; // Don't care
  localparam bm_rdat  = 3'd0; // Use data from register file
  localparam bm_si    = 3'd1; // Use sign-extended immediate
  localparam bm_pc4   = 3'd2; // PC+4
  localparam bm_zi    = 3'd3; // Use zero-extended immediate
  localparam bm_fhst  = 3'd4; // Use from mngr data


  // ALU Function

  localparam alu_x    = 4'bx;
  localparam alu_add  = 4'd0;
  localparam alu_sub  = 4'd1;
  localparam alu_sll  = 4'd2;
  localparam alu_or   = 4'd3;
  localparam alu_ltu  = 4'd4;
  localparam alu_and  = 4'd5;
  localparam alu_xor  = 4'd6;
  localparam alu_nor  = 4'd7;
  localparam alu_xnor = 4'd8;
  localparam alu_srl  = 4'd9;
  localparam alu_sra  = 4'd10;
  localparam alu_cp0  = 4'd11;
  localparam alu_cp1  = 4'd12;
  localparam alu_lts  = 4'd13;
  localparam alu_lui  = 4'd14;

  // EX Mux sel

  localparam alu_out = 1'b0;
  localparam mul_out = 1'b1;

  // Memory Request Type

  localparam nr       = 2'd0; // No request
  localparam ld       = 2'd1; // Load
  localparam st       = 2'd2; // Store

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
  logic       ex_mux_sel_D;
  logic [1:0] dmemreq_type_D;
  logic       wb_result_sel_D;
  logic       rf_wen_D;
  logic [4:0] rf_waddr_D;
  logic       to_mngr_val_D;
  logic       from_mngr_rdy_D;

  localparam nB = 2'd0;
  localparam bX = 2'd1;
  localparam bM = 2'd2;
  localparam bW = 2'd3;

  always @(*) begin
    if ( (rs_en_D && val_X && rf_wen_X && rf_waddr_X == inst_rs_D) && (rf_waddr_X != r0) ) begin
        casez (inst_X)
          `PISA_INST_LW : bypass_rs = nB;
          default       : bypass_rs = bX;
        endcase
    end
    else if ((rs_en_D) && val_M && (rf_wen_M) && (rf_waddr_M == inst_rs_D) && (rf_waddr_M != r0)) begin
      bypass_rs = bM;
    end
    else begin
      bypass_rs = nB;
    end
  end

  always @(*) begin
    if ( (rt_en_D && val_X && rf_wen_X && rf_waddr_X == inst_rt_D) && (rf_waddr_X != r0) ) begin
        casez (inst_X)
          `PISA_INST_LW : bypass_rt = nB;
          default       : bypass_rt = bX;
        endcase
    end
    else if ((rt_en_D) && val_M && (rf_wen_M) && (rf_waddr_M == inst_rt_D) && (rf_waddr_M != r0)) begin
      bypass_rt = bM;
    end
    else begin
      bypass_rt = nB;
    end
  end

  task cs
  (
    input logic       cs_val,
    input logic [1:0] cs_j_type,
    input logic [2:0] cs_br_type,
    input logic [2:0] cs_op0_sel,
    input logic       cs_rs_en,
    input logic [2:0] cs_op1_sel,
    input logic       cs_rt_en,
    input logic [3:0] cs_alu_fn,
    input logic       cs_mux_sel_D,
    input logic [1:0] cs_dmemreq_type,
    input logic       cs_wb_result_sel,
    input logic       cs_rf_wen,
    input logic [4:0] cs_rf_waddr,
    input logic       cs_to_mngr_val,
    input logic       cs_from_mngr_rdy
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
    ex_mux_sel_D     = cs_mux_sel_D;
    dmemreq_type_D   = cs_dmemreq_type;
    wb_result_sel_D  = cs_wb_result_sel;
    rf_wen_D         = cs_rf_wen;
    rf_waddr_D       = cs_rf_waddr;
    to_mngr_val_D    = cs_to_mngr_val;
    from_mngr_rdy_D  = cs_from_mngr_rdy;
  end
  endtask


  always @ (*) begin

    casez ( inst_D )

      //                          j    br        op0      rs op1      rt alu      exmux   dmm wbmux rf      thst fhst
      //                      val type type      muxsel   en muxsel   en fn       sel     typ sel   wen wa  val  rdy
      `PISA_INST_NOP     :cs( y,  j_n, br_none, am_x,     n, bm_x,    n, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_MUL     :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_x,   mul_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_ADDU    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_add, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SUBU    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_sub, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_AND     :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_and, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_OR      :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_or,  alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_XOR     :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_xor, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_NOR     :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_nor, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRAV    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_sra, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRLV    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_srl, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLLV    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_sll, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLL     :cs( y,  j_n, br_none, am_shamt, n, bm_rdat, y, alu_sll, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRA     :cs( y,  j_n, br_none, am_shamt, n, bm_rdat, y, alu_sra, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SRL     :cs( y,  j_n, br_none, am_shamt, n, bm_rdat, y, alu_srl, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLT     :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_lts, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_SLTU    :cs( y,  j_n, br_none, am_rdat,  y, bm_rdat, y, alu_ltu, alu_out, nr, wm_a, y,  rd, n,   n   );
      `PISA_INST_ADDIU   :cs( y,  j_n, br_none, am_rdat,  y, bm_si,   n, alu_add, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_ORI     :cs( y,  j_n, br_none, am_rdat,  y, bm_zi,   n, alu_or,  alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_ANDI    :cs( y,  j_n, br_none, am_rdat,  y, bm_zi,   n, alu_and, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_XORI    :cs( y,  j_n, br_none, am_rdat,  y, bm_zi,   n, alu_xor, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_SLTI    :cs( y,  j_n, br_none, am_rdat,  y, bm_si,   y, alu_lts, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_SLTIU   :cs( y,  j_n, br_none, am_rdat,  y, bm_si,   y, alu_ltu, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_LUI     :cs( y,  j_n, br_none, am_x,     n, bm_zi,   n, alu_lui, alu_out, nr, wm_a, y,  rt, n,   n   );
      `PISA_INST_BNE     :cs( y,  j_n, br_ne,   am_rdat,  y, bm_rdat, y, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_BEQ     :cs( y,  j_n, br_eq,   am_rdat,  y, bm_rdat, y, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_BGTZ    :cs( y,  j_n, br_gtz,  am_rdat,  y, bm_x,    n, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_BLTZ    :cs( y,  j_n, br_ltz,  am_rdat,  y, bm_x,    n, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_BGEZ    :cs( y,  j_n, br_gez,  am_rdat,  y, bm_x,    n, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_BLEZ    :cs( y,  j_n, br_lez,  am_rdat,  y, bm_x,    n, alu_x,   alu_out, nr, wm_a, n,  rx, n,   n   );
      `PISA_INST_J       :cs( y,  j_j, br_none, am_x,     n, bm_x,    n, alu_x,   alu_out, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_JR      :cs( y,  j_r, br_none, am_rdat,  y, bm_x,    n, alu_x,   alu_out, nr, wm_x, n,  rx, n,   n   );
      `PISA_INST_JAL     :cs( y,  j_l, br_none, am_x,     n, bm_pc4,  n, alu_cp1, alu_out, nr, wm_a, y,  rL, n,   n   );
      `PISA_INST_LW      :cs( y,  j_n, br_none, am_rdat,  y, bm_si,   n, alu_add, alu_out, ld, wm_m, y,  rt, n,   n   );
      `PISA_INST_SW      :cs( y,  j_n, br_none, am_rdat,  y, bm_si,   y, alu_add, alu_out, st, wm_x, n,  rx, n,   n   );
      `PISA_INST_MFC0    :cs( y,  j_n, br_none, am_x,     n, bm_fhst, n, alu_cp1, alu_out, nr, wm_a, y,  rt, n,   y   );
      `PISA_INST_MTC0    :cs( y,  j_n, br_none, am_x,     n, bm_rdat, y, alu_cp1, alu_out, nr, wm_a, n,  rx, y,   n   );
      default            :cs( n,  j_x, br_x,    am_x,     n, bm_x,    n, alu_x,   alu_out, nr, wm_x, n,  rx, n,   n   );

    endcase
  end

  logic stall_from_mngr_D;
  logic stall_hazard_D;

  // jump logic

  logic      squash_j_D;

  always @(*) begin
    if ( val_D ) begin

      case ( j_type_D )
        j_j:     j_pc_sel_D = pm_j;
        j_r:     j_pc_sel_D = pm_r;
        j_l:     j_pc_sel_D = pm_j;
        default: j_pc_sel_D = pm_p;
      endcase

    end else
      j_pc_sel_D = pm_p;
  end

  assign j_taken_D = ( j_pc_sel_D != pm_p );

  assign squash_j_D = j_taken_D;

  // from mngr rdy signal for mfc0 instruction

  assign from_mngr_rdy     = ( val_D && from_mngr_rdy_D && !stall_FD );
  assign stall_from_mngr_D = ( val_D && from_mngr_rdy_D && !from_mngr_val );

  // Stall if write address in X matches rs in D

  logic  stall_waddr_X_rs_D;
  assign stall_waddr_X_rs_D
    = ( rs_en_D && val_X && rf_wen_X
        && ( inst_rs_D == rf_waddr_X ) && ( rf_waddr_X != 5'd0 ) && (bypass_rs == nB) );

  // Stall if write address in M matches rs in D

  logic  stall_waddr_M_rs_D;
  assign stall_waddr_M_rs_D
    = ((bypass_rs == bM) && (stall_dmem_M));

  // Stall if write address in W matches rs in D

  logic  stall_waddr_W_rs_D;
  assign stall_waddr_W_rs_D
    = ( rs_en_D && val_W && rf_wen_W
        && ( inst_rs_D == rf_waddr_W ) && ( rf_waddr_W != 5'd0 ) );

  // Stall if write address in X matches rt in D

  logic  stall_waddr_X_rt_D;
  assign stall_waddr_X_rt_D
    = ( rt_en_D && val_X && rf_wen_X
        && ( inst_rt_D == rf_waddr_X ) && ( rf_waddr_X != 5'd0 ) && (bypass_rs == nB) ); 

  // Stall if write address in M matches rt in D

  logic  stall_waddr_M_rt_D;
  assign stall_waddr_M_rt_D
    = ((bypass_rt == bM) && (stall_dmem_M));

  // Stall if write address in W matches rt in D

  logic  stall_waddr_W_rt_D;
  assign stall_waddr_W_rt_D
    = ( rt_en_D && val_W && rf_wen_W
        && ( inst_rt_D == rf_waddr_W ) && ( rf_waddr_W != 5'd0 ) );

  // Put together final stall signal

  assign stall_hazard_D = val_D &&
    ( stall_waddr_X_rs_D || stall_waddr_M_rs_D || stall_waddr_W_rs_D ||
      stall_waddr_X_rt_D || stall_waddr_M_rt_D || stall_waddr_W_rt_D );


  logic mulreq_val_D;
  logic stall_mul_D;

  assign mulreq_val_D = val_D && ( ex_mux_sel_D == mul_out);
  assign mulreq_val = mulreq_val_D && !stall_DX && !stall_hazard_D && !stall_from_mngr_D;  

  // Stall if multiplier not ready
  assign stall_mul_D = mulreq_val_D && !mulreq_rdy;

  assign stall_D  = stall_from_mngr_D || stall_hazard_D || stall_mul_D;
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
  logic [1:0]  dmemreq_type_X;
  logic        wb_result_sel_X;
  logic        rf_wen_X;
  logic [4:0]  rf_waddr_X;
  logic        to_mngr_val_X;
  logic [2:0]  br_type_X;

  always @(posedge clk) begin
    if (reset) begin
      rf_wen_X      <= 1'b0;
    end else if (reg_en_X) begin
      inst_X          <= inst_D;
      alu_fn_X        <= alu_fn_D;
      ex_mux_sel_X    <= ex_mux_sel_D;
      dmemreq_type_X  <= dmemreq_type_D;
      wb_result_sel_X <= wb_result_sel_D;
      rf_wen_X        <= rf_wen_D;
      rf_waddr_X      <= rf_waddr_D;
      to_mngr_val_X   <= to_mngr_val_D;
      br_type_X       <= br_type_D;
    end
  end

  // branch logic

  logic        squash_br_X;

  always @(*) begin
    if ( val_X ) begin

      case ( br_type_X )
        br_ne:  br_taken_X = !br_cond_eq_X;
        br_eq:  br_taken_X = br_cond_eq_X;
        br_gtz: br_taken_X = !br_cond_zero_X && !br_cond_neg_X;
        br_ltz: br_taken_X = br_cond_neg_X;
        br_gez: br_taken_X = br_cond_zero_X || !br_cond_neg_X;
        br_lez: br_taken_X = br_cond_zero_X || br_cond_neg_X;
        default: br_taken_X = 1'b0;
      endcase
    end else
      br_taken_X = 1'b0;
  end

  // squash the previous instructions on branch

  assign squash_br_X = br_taken_X;

  logic dmemreq_val_X;
  logic stall_dmem_X;


  assign dmemreq_val_X = val_X && ( dmemreq_type_X != nr );
  assign dmemreq_val  = dmemreq_val_X && !stall_XM;
  assign dmemreq_type = ( dmemreq_type_X == st ? `VC_MEM_REQ_MSG_TYPE_WRITE 
                                               : `VC_MEM_REQ_MSG_TYPE_READ);

  assign stall_dmem_X = dmemreq_val_X && !dmemreq_rdy;
  
  logic mulresp_val_X;
  logic stall_mul_X;

  assign mulresp_val_X = val_X && ( ex_mux_sel_X == mul_out);
  assign mulresp_rdy = mulresp_val_X && !stall_XM;

  // Stall if multiplier not ready
  assign stall_mul_X = mulresp_val_X && !mulresp_val;
  // stall in X if dmem is not rdy
  assign stall_X  = stall_dmem_X || stall_mul_X; 
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
  logic [1:0]  dmemreq_type_M;
  logic        rf_wen_M;
  logic [4:0]  rf_waddr_M;
  logic        to_mngr_val_M;

  always @(posedge clk) begin
    if (reset) begin
      rf_wen_M        <= 1'b0;
    end else if (reg_en_M) begin
      inst_M          <= inst_X;
      dmemreq_type_M  <= dmemreq_type_X;
      wb_result_sel_M <= wb_result_sel_X;
      rf_wen_M        <= rf_wen_X;
      rf_waddr_M      <= rf_waddr_X;
      to_mngr_val_M   <= to_mngr_val_X;
    end
  end

  logic dmemreq_val_M;
  logic stall_dmem_M;

  assign dmemresp_rdy = dmemreq_val_M && !stall_MW;

  assign dmemreq_val_M = val_M && ( dmemreq_type_M != nr );
  assign stall_dmem_M  = ( dmemreq_val_M && !dmemresp_val );

  assign stall_M  = stall_dmem_M;
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
    end else if (reg_en_W) begin
      inst_W        <= inst_M;
      rf_wen_W      <= rf_wen_M;
      rf_waddr_W    <= rf_waddr_M;
      to_mngr_val_W <= to_mngr_val_M;
    end
  end

  assign to_mngr_val     = ( val_W && to_mngr_val_W && !stall_MW );
  assign stall_to_mngr_W = ( val_W && to_mngr_val_W && !to_mngr_rdy );

  assign stall_W  = stall_to_mngr_W;
  assign squash_W = 1'b0;

endmodule


`endif
