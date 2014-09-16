#=========================================================================
# lab2-proc Subpackage
#=========================================================================

lab2_proc_deps = \
  vc \
  pisa \
  lab1-imul \

lab2_proc_srcs = \
	lab2-proc-alu.v \
	lab2-proc-brj-target-calc.v \
	lab2-proc-regfile.v \
  lab2-proc-ISASimulator.v \
  lab2-proc-PipelinedProcBaseDpath.v \
  lab2-proc-PipelinedProcBaseCtrl.v \
  lab2-proc-PipelinedProcBase.v \

lab2_proc_gen_isa_test_srcs = \
  lab2-proc-ISASimulator-mngr.t.v \
  lab2-proc-ISASimulator-addu.t.v \
  lab2-proc-ISASimulator-lw.t.v \
  lab2-proc-ISASimulator-bne.t.v \
  lab2-proc-ISASimulator-beq.t.v \
  lab2-proc-ISASimulator-bgtz.t.v \
  lab2-proc-ISASimulator-bgez.t.v \
  lab2-proc-ISASimulator-bltz.t.v \
  lab2-proc-ISASimulator-blez.t.v \
  lab2-proc-ISASimulator-addiu.t.v \
  lab2-proc-ISASimulator-ori.t.v \
  lab2-proc-ISASimulator-andi.t.v \
  lab2-proc-ISASimulator-xori.t.v \
  lab2-proc-ISASimulator-sra.t.v \
  lab2-proc-ISASimulator-srav.t.v \
  lab2-proc-ISASimulator-srl.t.v \
  lab2-proc-ISASimulator-srlv.t.v \
  lab2-proc-ISASimulator-sll.t.v \
  lab2-proc-ISASimulator-sllv.t.v \
  lab2-proc-ISASimulator-lui.t.v \
  lab2-proc-ISASimulator-subu.t.v \
  lab2-proc-ISASimulator-slt.t.v \
  lab2-proc-ISASimulator-sltu.t.v \
  lab2-proc-ISASimulator-slti.t.v \
  lab2-proc-ISASimulator-sltiu.t.v \
  lab2-proc-ISASimulator-and.t.v \
  lab2-proc-ISASimulator-or.t.v \
  lab2-proc-ISASimulator-mul.t.v \
  lab2-proc-ISASimulator-sw.t.v \
  lab2-proc-ISASimulator-j.t.v \
  lab2-proc-ISASimulator-jal.t.v \
  lab2-proc-ISASimulator-jr.t.v \
  lab2-proc-ISASimulator-xor.t.v \
  lab2-proc-ISASimulator-nor.t.v \

lab2_proc_gen_base_test_srcs = \
  lab2-proc-PipelinedProcBase-mngr.t.v \
  lab2-proc-PipelinedProcBase-addu.t.v \
  lab2-proc-PipelinedProcBase-lw.t.v \
  lab2-proc-PipelinedProcBase-bne.t.v \
  lab2-proc-PipelinedProcBase-beq.t.v \
  lab2-proc-PipelinedProcBase-bgtz.t.v \
  lab2-proc-PipelinedProcBase-bgez.t.v \
  lab2-proc-PipelinedProcBase-bltz.t.v \
  lab2-proc-PipelinedProcBase-blez.t.v \
  lab2-proc-PipelinedProcBase-addiu.t.v \
  lab2-proc-PipelinedProcBase-ori.t.v \
  lab2-proc-PipelinedProcBase-andi.t.v \
  lab2-proc-PipelinedProcBase-xori.t.v \
  lab2-proc-PipelinedProcBase-sra.t.v \
  lab2-proc-PipelinedProcBase-srav.t.v \
  lab2-proc-PipelinedProcBase-srl.t.v \
  lab2-proc-PipelinedProcBase-srlv.t.v \
  lab2-proc-PipelinedProcBase-sll.t.v \
  lab2-proc-PipelinedProcBase-sllv.t.v \
  lab2-proc-PipelinedProcBase-lui.t.v \
  lab2-proc-PipelinedProcBase-subu.t.v \
  lab2-proc-PipelinedProcBase-slt.t.v \
  lab2-proc-PipelinedProcBase-sltu.t.v \
  lab2-proc-PipelinedProcBase-slti.t.v \
  lab2-proc-PipelinedProcBase-sltiu.t.v \
  lab2-proc-PipelinedProcBase-and.t.v \
  lab2-proc-PipelinedProcBase-or.t.v \
  lab2-proc-PipelinedProcBase-mul.t.v \
  lab2-proc-PipelinedProcBase-sw.t.v \
  lab2-proc-PipelinedProcBase-j.t.v \
  lab2-proc-PipelinedProcBase-jal.t.v \
  lab2-proc-PipelinedProcBase-jr.t.v \
  lab2-proc-PipelinedProcBase-xor.t.v \
  lab2-proc-PipelinedProcBase-nor.t.v \

lab2_proc_gen_alt_test_srcs = \
  lab2-proc-PipelinedProcAlt-mngr.t.v \
  lab2-proc-PipelinedProcAlt-addu.t.v \
  lab2-proc-PipelinedProcAlt-lw.t.v \
  lab2-proc-PipelinedProcAlt-bne.t.v \
  lab2-proc-PipelinedProcAlt-beq.t.v \
  lab2-proc-PipelinedProcAlt-bgtz.t.v \
  lab2-proc-PipelinedProcAlt-bgez.t.v \
  lab2-proc-PipelinedProcAlt-bltz.t.v \
  lab2-proc-PipelinedProcAlt-blez.t.v \
  lab2-proc-PipelinedProcAlt-addiu.t.v \
  lab2-proc-PipelinedProcAlt-ori.t.v \
  lab2-proc-PipelinedProcAlt-andi.t.v \
  lab2-proc-PipelinedProcAlt-xori.t.v \
  lab2-proc-PipelinedProcAlt-sra.t.v \
  lab2-proc-PipelinedProcAlt-srav.t.v \
  lab2-proc-PipelinedProcAlt-srl.t.v \
  lab2-proc-PipelinedProcAlt-srlv.t.v \
  lab2-proc-PipelinedProcAlt-sll.t.v \
  lab2-proc-PipelinedProcAlt-sllv.t.v \
  lab2-proc-PipelinedProcAlt-lui.t.v \
  lab2-proc-PipelinedProcAlt-subu.t.v \
  lab2-proc-PipelinedProcAlt-slt.t.v \
  lab2-proc-PipelinedProcAlt-sltu.t.v \
  lab2-proc-PipelinedProcAlt-slti.t.v \
  lab2-proc-PipelinedProcAlt-sltiu.t.v \
  lab2-proc-PipelinedProcAlt-and.t.v \
  lab2-proc-PipelinedProcAlt-or.t.v \
  lab2-proc-PipelinedProcAlt-mul.t.v \
  lab2-proc-PipelinedProcAlt-sw.t.v \
  lab2-proc-PipelinedProcAlt-j.t.v \
  lab2-proc-PipelinedProcAlt-jal.t.v \
  lab2-proc-PipelinedProcAlt-jr.t.v \
  lab2-proc-PipelinedProcAlt-xor.t.v \
  lab2-proc-PipelinedProcAlt-nor.t.v \

lab2_proc_test_srcs = \
	lab2-proc-alu.t.v \
	lab2-proc-brj-target-calc.t.v \
	lab2-proc-regfile.t.v \
	$(lab2_proc_gen_isa_test_srcs) \
	$(lab2_proc_gen_base_test_srcs) \
	$(lab2_proc_gen_alt_test_srcs) \

lab2_proc_sim_srcs = \
  lab2-proc-sim-isa.v \
  lab2-proc-sim-base.v \
  lab2-proc-sim-alt.v \

#-------------------------------------------------------------------------
# Rules to generate test harnesses based on instructions
#-------------------------------------------------------------------------

$(lab2_proc_gen_simple_test_srcs) : lab2-proc-PipelinedProcSimple-%.t.v \
	: lab2-proc-PipelinedProcSimple.t.v lab2-proc-test-cases-%.v \
	lab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(lab2_proc_gen_base_test_srcs) : lab2-proc-PipelinedProcBase-%.t.v \
	: lab2-proc-PipelinedProcBase.t.v lab2-proc-test-cases-%.v \
	lab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(lab2_proc_gen_alt_test_srcs) : lab2-proc-PipelinedProcAlt-%.t.v \
	: lab2-proc-PipelinedProcAlt.t.v lab2-proc-test-cases-%.v \
	lab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(lab2_proc_gen_isa_test_srcs) : lab2-proc-ISASimulator-%.t.v \
	: lab2-proc-ISASimulator.t.v lab2-proc-test-cases-%.v \
	lab2-proc-isa-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

lab2_proc_eval_impls  = base alt
lab2_proc_eval_inputs = \
  vvadd-unopt \
  vvadd-opt \
  cmplx-mult \
  bin-search \
  masked-filter \

# Template used to create rules for each impl/input pair

define lab2_proc_eval_template

lab2_proc_eval_outs += lab2-proc-sim-$(1)-$(2).out

lab2-proc-sim-$(1)-$(2).out : lab2-proc-sim-$(1)
	./$$< +input=$(2) +stats +verify | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(lab2_proc_eval_impls), \
  $(foreach dataset,$(lab2_proc_eval_inputs), \
    $(eval $(call lab2_proc_eval_template,$(impl),$(dataset)))))

lab2_proc_junk += $(lab2_proc_eval_outs)

# Grep all evaluation results

eval-lab2-proc : $(lab2_proc_eval_outs)
	@echo ""
	@echo "Verify:"
	@grep "\[ passed \]\|\[ FAILED \]" $^ | column -s ":=" -t
	@echo ""
	@echo "CPI:"
	@grep avg_num_cycles_per_inst $^ | column -s ":=" -t
	@echo ""


