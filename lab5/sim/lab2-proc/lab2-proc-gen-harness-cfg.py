#=========================================================================
# Configuration file for generating the lab harness
#=========================================================================

include_full_subpkgs = [
  "vc",
  "ex-regincr",
  "ex-sorter",
  "ex-gcd",
  "pisa",
]

include_partial_subpkgs = [
  "lab2-proc",
]

include_partial_subpkgs_full_files = [
  "lab2-proc/lab2-proc-brj-target-calc.v",
  "lab2-proc/lab2-proc-regfile.v",
  "lab2-proc/lab2-proc-brj-target-calc.t.v",
  "lab2-proc/lab2-proc-regfile.t.v",
  "lab2-proc/lab2-proc-ISASimulator.t.v",
  "lab2-proc/lab2-proc-ISASimulator.v",
  "lab2-proc/lab2-proc-PipelinedProcSimple.t.v",
  "lab2-proc/lab2-proc-PipelinedProcSimple.v",
  "lab2-proc/lab2-proc-PipelinedProcSimpleCtrl.v",
  "lab2-proc/lab2-proc-PipelinedProcSimpleDpath.v",
  "lab2-proc/lab2-proc-PipelinedProcAlt.t.v",
  "lab2-proc/lab2-proc-sim-harness.v",
  "lab2-proc/lab2-proc-isa-sim-harness.v",
  "lab2-proc/lab2-proc-sim-base.v",
  "lab2-proc/lab2-proc-sim-alt.v",
  "lab2-proc/lab2-proc-sim-isa.v",
  "lab2-proc/lab2-proc-ubmark-vvadd.v",
  "lab2-proc/lab2-proc-ubmark-masked-filter.v",
  "lab2-proc/lab2-proc-ubmark-cmplx-mult.v",
  "lab2-proc/lab2-proc-ubmark-bin-search.v",
  "lab2-proc/lab2-proc-test-cases-addu.v",
  "lab2-proc/lab2-proc-test-cases-addiu.v",
  "lab2-proc/lab2-proc-test-cases-bne.v",
  "lab2-proc/lab2-proc-test-cases-j.v",
  "lab2-proc/lab2-proc-test-cases-lw.v",
  "lab2-proc/lab2-proc-test-cases-mngr.v",
]

include_partial_subpkgs_strip_files = [
  "lab2-proc/lab2-proc-alu.v",
  "lab2-proc/lab2-proc-alu.t.v",
  "lab2-proc/lab2-proc.mk",
  "lab2-proc/lab2-proc-PipelinedProcAlt.v",
  "lab2-proc/lab2-proc-PipelinedProcAltCtrl.v",
  "lab2-proc/lab2-proc-PipelinedProcAltDpath.v",
  "lab2-proc/lab2-proc-isa-test-harness.v",
  "lab2-proc/lab2-proc-test-harness.v",
  "lab2-proc/lab2-proc-test-cases-andi.v",
  "lab2-proc/lab2-proc-test-cases-and.v",
  "lab2-proc/lab2-proc-test-cases-beq.v",
  "lab2-proc/lab2-proc-test-cases-bgez.v",
  "lab2-proc/lab2-proc-test-cases-bgtz.v",
  "lab2-proc/lab2-proc-test-cases-blez.v",
  "lab2-proc/lab2-proc-test-cases-bltz.v",
  "lab2-proc/lab2-proc-test-cases-jal.v",
  "lab2-proc/lab2-proc-test-cases-jr.v",
  "lab2-proc/lab2-proc-test-cases-lui.v",
  "lab2-proc/lab2-proc-test-cases-mul.v",
  "lab2-proc/lab2-proc-test-cases-nor.v",
  "lab2-proc/lab2-proc-test-cases-ori.v",
  "lab2-proc/lab2-proc-test-cases-or.v",
  "lab2-proc/lab2-proc-test-cases-sll.v",
  "lab2-proc/lab2-proc-test-cases-sllv.v",
  "lab2-proc/lab2-proc-test-cases-sltiu.v",
  "lab2-proc/lab2-proc-test-cases-slti.v",
  "lab2-proc/lab2-proc-test-cases-sltu.v",
  "lab2-proc/lab2-proc-test-cases-slt.v",
  "lab2-proc/lab2-proc-test-cases-sra.v",
  "lab2-proc/lab2-proc-test-cases-srav.v",
  "lab2-proc/lab2-proc-test-cases-srl.v",
  "lab2-proc/lab2-proc-test-cases-srlv.v",
  "lab2-proc/lab2-proc-test-cases-subu.v",
  "lab2-proc/lab2-proc-test-cases-sw.v",
  "lab2-proc/lab2-proc-test-cases-xori.v",
  "lab2-proc/lab2-proc-test-cases-xor.v",
]

