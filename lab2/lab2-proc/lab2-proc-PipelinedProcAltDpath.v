//=========================================================================
// 5-Stage Bypass Pipelined Processor Datapath
//=========================================================================

`ifndef LAB2_PROC_PIPELINED_PROC_ALT_DPATH_V
`define LAB2_PROC_PIPELINED_PROC_ALT_DPATH_V

`include "lab2-proc-alu.v"
`include "lab2-proc-brj-target-calc.v"
`include "lab2-proc-regfile.v"
`include "lab1-imul-IntMulAlt.v"
`include "vc-arithmetic.v"
`include "vc-mem-msgs.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "pisa-inst.v"

module lab2_proc_PipelinedProcAltDpath
#(
  parameter p_num_cores = 1,
  parameter p_core_id   = 0
)
(
  input  logic        clk,
  input  logic        reset,

  // Instruction Memory Port

  output logic [31:0]                             imemreq_msg_addr,
  input  logic [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0] imemresp_msg,
  input  logic                                    imemresp_val,
  output logic                                    imemresp_rdy,

  // Data Memory Port

  output logic [31:0] dmemreq_msg_addr,
  output logic [31:0] dmemreq_msg_data,
  input  logic [31:0] dmemresp_msg_data,

  // mngr communication ports

  input  logic [31:0] from_mngr_data,
  output logic [31:0] to_mngr_data,

  // MUL signals

  input  logic mulreq_val,
  output logic mulreq_rdy,

  output logic mulresp_val,
  input  logic mulresp_rdy,

  // control signals (ctrl->dpath)

  output logic        imemresp_val_drop,
  input  logic        imemresp_rdy_drop,
  input  logic        imemresp_drop,
  input  logic [1:0]  pc_sel_F,
  input  logic        reg_en_F,
  input  logic        reg_en_D,
  input  logic        reg_en_X,
  input  logic        reg_en_M,
  input  logic        reg_en_W,
  input  logic [1:0]  op0_sel_D,
  input  logic [2:0]  op1_sel_D,
  input  logic [3:0]  alu_fn_X,
  input  logic        ex_mux_sel_X,
  input  logic        wb_result_sel_M,
  input  logic [4:0]  rf_waddr_W,
  input  logic        rf_wen_W,

  input  logic [1:0]  bypass_rs,
  input  logic [1:0]  bypass_rt,

  // status signals (dpath->ctrl)

  output logic [31:0] inst_D,
  output logic        br_cond_eq_X,
  output logic        br_cond_neg_X,
  output logic        br_cond_zero_X
);

  localparam c_reset_vector = 32'h1000;
  localparam c_reset_inst   = 32'h00000000;

  // Fetch address

  assign imemreq_msg_addr = pc_next_F;

  //--------------------------------------------------------------------
  // F stage
  //--------------------------------------------------------------------

  logic [31:0] pc_F;
  logic [31:0] pc_next_F;
  logic [31:0] pc_plus4_F;
  logic [31:0] br_target_X;
  logic [31:0] j_target_D;
  logic [31:0] jr_target_D;

  vc_EnResetReg #(32, c_reset_vector - 32'd4) pc_reg_F
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_F),
    .d      (pc_next_F),
    .q      (pc_F)
  );

  vc_Incrementer #(32, 4) pc_incr_F
  (
    .in   (pc_F),
    .out  (pc_plus4_F)
  );

  vc_Mux4 #(32) pc_sel_mux_F
  (
    .in0  (br_target_X),
    .in1  (jr_target_D),
    .in2  (j_target_D),
    .in3  (pc_plus4_F),
    .sel  (pc_sel_F),
    .out  (pc_next_F)
  );

  // Imem Drop Unit

  logic [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0] imemresp_msg_drop;

  vc_DropUnit #(`VC_MEM_RESP_MSG_NBITS(8,32)) imem_drop_unit
  (
    .clk      (clk),
    .reset    (reset),

    .drop     (imemresp_drop),

    .in_msg   (imemresp_msg),
    .in_val   (imemresp_val),
    .in_rdy   (imemresp_rdy),

    .out_msg  (imemresp_msg_drop),
    .out_val  (imemresp_val_drop),
    .out_rdy  (imemresp_rdy_drop)
  );

  // Unpack Memory Response Message

  logic [31:0] imemresp_msg_data;

  vc_MemRespMsgUnpack#(8,32) imemresp_msg_unpack
  (
    .msg    (imemresp_msg_drop),
    .opaque (),
    .type_  (),
    .len    (),
    .data   (imemresp_msg_data)
  );

  //--------------------------------------------------------------------
  // D stage
  //--------------------------------------------------------------------

  logic  [31:0] pc_plus4_D;
  logic   [4:0] inst_rs_D;
  logic   [4:0] inst_rt_D;
  logic   [4:0] inst_rd_D;
  logic   [4:0] inst_shamt_D;
  logic  [15:0] inst_imm_D;
  logic  [31:0] inst_imm_sext_D;
  logic  [31:0] inst_imm_zext_D;
  logic  [31:0] inst_shift_zext_D;
  logic  [25:0] inst_target_D;

  logic  [31:0] bypass_rs_rt_X;
  logic  [31:0] bypass_rs_rt_M;
  logic  [31:0] bypass_rs_rt_W;

  vc_EnResetReg #(32) pc_plus4_reg_D
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_D),
    .d      (pc_plus4_F),
    .q      (pc_plus4_D)
  );

  vc_EnResetReg #(32, c_reset_inst) inst_D_reg
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_D),
    .d      (imemresp_msg_data),
    .q      (inst_D)
  );

  pisa_InstUnpack inst_unpack
  (
    .inst     (inst_D),
    .opcode   (),
    .rs       (inst_rs_D),
    .rt       (inst_rt_D),
    .rd       (inst_rd_D),
    .shamt    (inst_shamt_D),
    .func     (),
    .imm      (inst_imm_D),
    .target   (inst_target_D)
  );

  logic [ 4:0] rf_raddr0_D; assign rf_raddr0_D = inst_rs_D;
  logic [31:0] rf_rdata0_D;
  logic [ 4:0] rf_raddr1_D; assign rf_raddr1_D = inst_rt_D;
  logic [31:0] rf_rdata1_D;

  logic [31:0] rf_wdata_W;

  lab2_proc_Regfile rfile
  (
    .clk         (clk),
    .reset       (reset),
    .read_addr0  (rf_raddr0_D),
    .read_data0  (rf_rdata0_D),
    .read_addr1  (rf_raddr1_D),
    .read_data1  (rf_rdata1_D),
    .write_en    (rf_wen_W),
    .write_addr  (rf_waddr_W),
    .write_data  (rf_wdata_W)
  );

  logic [31:0] op0_D;
  logic [31:0] op1_D;

  vc_SignExtender #(16, 32) imm_sext_D
  (
    .in   (inst_imm_D),
    .out  (inst_imm_sext_D)
  );

  vc_ZeroExtender #(16, 32) imm_zext_D
  (
    .in   (inst_imm_D),
    .out  (inst_imm_zext_D)
  );

  vc_ZeroExtender #(5, 32) shamt_zext_D
  (
    .in   (inst_shamt_D),
    .out  (inst_shift_zext_D)
  );

  logic [31:0] no_byp_op0;
  logic [31:0] no_byp_op1;

  vc_Mux3 #(32) op0_sel_mux_D
  (
    .in0  (inst_shift_zext_D),
    .in1  (rf_rdata0_D),
    .in2  (32'd16),
    .sel  (op0_sel_D),
    .out  (no_byp_op0)
  );

  vc_Mux5 #(32) op1_sel_mux_D
  (
    .in0  (rf_rdata1_D),
    .in1  (inst_imm_sext_D),
    .in2  (pc_plus4_D),
    .in3  (inst_imm_zext_D),
    .in4  (from_mngr_data),
    .sel  (op1_sel_D),
    .out  (no_byp_op1)
  );

  vc_Mux4 #(32) op0_byp_mux_D
  (
    .in0  (no_byp_op0),
    .in1  (bypass_rs_rt_X),
    .in2  (bypass_rs_rt_M),
    .in3  (bypass_rs_rt_W),
    .sel  (bypass_rs),
    .out  (op0_D)
  );

  vc_Mux4 #(32) op1_byp_mux_D
  (
    .in0  (no_byp_op1),
    .in1  (bypass_rs_rt_X),
    .in2  (bypass_rs_rt_M),
    .in3  (bypass_rs_rt_W),
    .sel  (bypass_rt),
    .out  (op1_D)
  );

  logic [31:0] br_target_D;

  logic [63:0] mul_msg;
  assign mul_msg = { op0_D, op1_D };
  logic [31:0] mul_result_X;

  lab1_imul_IntMulAlt mul
  (
    .clk      (clk),
    .reset    (reset), //not sure if we ever want to reset the mult
    .req_val  (mulreq_val),
    .req_rdy  (mulreq_rdy),
    .req_msg  (mul_msg),
    .resp_val (mulresp_val),
    .resp_rdy (mulresp_rdy),
    .resp_msg (mul_result_X)
  );

  lab2_proc_BrTarget br_target_calc_D
  (
    .pc_plus4  (pc_plus4_D),
    .imm_sext  (inst_imm_sext_D),
    .br_target (br_target_D)
  );

  lab2_proc_JTarget j_target_calc_D
  (
    .pc_plus4   (pc_plus4_D),
    .imm_target (inst_target_D),
    .j_target   (j_target_D)
  );

  logic [31:0] write_data_D;

  vc_Mux4 #(32) dmem_write_data_mux_D
  (
    .in0  (rf_rdata1_D),
    .in1  (bypass_rs_rt_X),
    .in2  (bypass_rs_rt_M),
    .in3  (bypass_rs_rt_W),
    .sel  (bypass_rt),
    .out  (write_data_D)
  );

  assign jr_target_D = rf_rdata0_D;

  //--------------------------------------------------------------------
  // X stage
  //--------------------------------------------------------------------

  logic [31:0] op0_X;
  logic [31:0] op1_X;
  logic [31:0] write_data_X;

  vc_EnResetReg #(32, 0) op0_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_X),
    .d      (op0_D),
    .q      (op0_X)
  );

  vc_EnResetReg #(32, 0) op1_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_X),
    .d      (op1_D),
    .q      (op1_X)
  );

  vc_EnResetReg #(32, 0) dmem_write_data_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_X),
    .d      (write_data_D),
    .q      (write_data_X)
  );

  vc_EnResetReg #(32, 0) br_target_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_X),
    .d      (br_target_D),
    .q      (br_target_X)
  );

  logic [31:0] alu_result_X;
  logic [31:0] ex_result_X;

  lab2_proc_alu alu
  (
    .in0      (op0_X),
    .in1      (op1_X),
    .fn       (alu_fn_X),
    .out      (alu_result_X),
    .ops_eq   (br_cond_eq_X),
    .op0_zero (br_cond_zero_X),
    .op0_neg  (br_cond_neg_X)
  );

  vc_Mux2 #(32) ex_result_mux_X
  (
    .in0  (alu_result_X),
    .in1  (mul_result_X),
    .sel  (ex_mux_sel_X),
    .out  (ex_result_X)
  );

  assign bypass_rs_rt_X = ex_result_X;
  assign dmemreq_msg_data = write_data_X;
  assign dmemreq_msg_addr = alu_result_X;

  //--------------------------------------------------------------------
  // M stage
  //--------------------------------------------------------------------

  logic [31:0] ex_result_M;

  vc_EnResetReg #(32, 0) ex_result_reg_M
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_M),
    .d      (ex_result_X),
    .q      (ex_result_M)
  );

  logic [31:0] dmem_result_M;
  logic [31:0] wb_result_M;

  assign dmem_result_M = dmemresp_msg_data;

  vc_Mux2 #(32) wb_result_sel_mux_M
  (
    .in0    (ex_result_M),
    .in1    (dmem_result_M),
    .sel    (wb_result_sel_M),
    .out    (wb_result_M)
  );

  assign bypass_rs_rt_M = wb_result_M;


  //--------------------------------------------------------------------
  // W stage
  //--------------------------------------------------------------------

  logic [31:0] wb_result_W;

  vc_EnResetReg #(32, 0) wb_result_reg_W
  (
    .clk    (clk),
    .reset  (reset),
    .en     (reg_en_W),
    .d      (wb_result_M),
    .q      (wb_result_W)
  );
  assign bypass_rs_rt_W = wb_result_W;
  assign to_mngr_data = wb_result_W;

  assign rf_wdata_W = wb_result_W;

endmodule

`endif

