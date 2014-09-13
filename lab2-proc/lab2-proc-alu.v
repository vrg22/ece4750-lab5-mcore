//========================================================================
// ALU for 5-Stage Pipelined Processor
//========================================================================

`ifndef LAB2_PROC_ALU_V
`define LAB2_PROC_ALU_V

module lab2_proc_alu
(
  input  logic [31:0] in0,
  input  logic [31:0] in1,
  input  logic [ 3:0] fn,
  output logic [31:0] out
);

  always @(*)
  begin

    case ( fn )
      4'd0  : out = in0 + in1;                     // ADD
      4'd1  : out = in0 - in1;                     // SUB
// add more functionality here for other ALU ops!

      default : out = 32'b0;
    endcase

  end

endmodule

`endif
