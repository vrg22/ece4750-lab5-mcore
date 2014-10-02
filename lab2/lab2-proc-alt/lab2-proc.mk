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
  lab2-proc-PipelinedProcAltDpath.v \
  lab2-proc-PipelinedProcAltCtrl.v \
  lab2-proc-PipelinedProcAlt.v \
	
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
	$(lab2_proc_gen_alt_test_srcs) \

lab2_proc_sim_srcs = \
  lab2-proc-sim-alt.v \

#-------------------------------------------------------------------------
# Rules to generate test harnesses based on instructions
#-------------------------------------------------------------------------

$(lab2_proc_gen_alt_test_srcs) : lab2-proc-PipelinedProcAlt-%.t.v \
	: lab2-proc-PipelinedProcAlt.t.v lab2-proc-test-cases-%.v \
	lab2-proc-test-harness.v
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


