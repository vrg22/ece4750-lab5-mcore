#=========================================================================
# lab5-mcore Subpackage
#=========================================================================

lab5_mcore_deps = \
  vc \
  pisa \
  lab1-imul \
  lab2-proc \
  lab3-mem \
  lab4-net \

lab5_mcore_srcs = \
  lab5-mcore-mem-net-adapters.v \
  lab5-mcore-MemNet.v \
  lab5-mcore-ProcCacheNetBase.v \
  lab5-mcore-ProcCacheNetAlt.v \

lab5_mcore_gen_base_test_srcs = \
  lab5-mcore-ProcCacheNetBase-mngr.t.v \
  lab5-mcore-ProcCacheNetBase-addu.t.v \
  lab5-mcore-ProcCacheNetBase-lw.t.v \
  lab5-mcore-ProcCacheNetBase-bne.t.v \
  lab5-mcore-ProcCacheNetBase-beq.t.v \
  lab5-mcore-ProcCacheNetBase-bgtz.t.v \
  lab5-mcore-ProcCacheNetBase-bgez.t.v \
  lab5-mcore-ProcCacheNetBase-bltz.t.v \
  lab5-mcore-ProcCacheNetBase-blez.t.v \
  lab5-mcore-ProcCacheNetBase-addiu.t.v \
  lab5-mcore-ProcCacheNetBase-ori.t.v \
  lab5-mcore-ProcCacheNetBase-andi.t.v \
  lab5-mcore-ProcCacheNetBase-xori.t.v \
  lab5-mcore-ProcCacheNetBase-sra.t.v \
  lab5-mcore-ProcCacheNetBase-srav.t.v \
  lab5-mcore-ProcCacheNetBase-srl.t.v \
  lab5-mcore-ProcCacheNetBase-srlv.t.v \
  lab5-mcore-ProcCacheNetBase-sll.t.v \
  lab5-mcore-ProcCacheNetBase-sllv.t.v \
  lab5-mcore-ProcCacheNetBase-lui.t.v \
  lab5-mcore-ProcCacheNetBase-subu.t.v \
  lab5-mcore-ProcCacheNetBase-slt.t.v \
  lab5-mcore-ProcCacheNetBase-sltu.t.v \
  lab5-mcore-ProcCacheNetBase-slti.t.v \
  lab5-mcore-ProcCacheNetBase-sltiu.t.v \
  lab5-mcore-ProcCacheNetBase-and.t.v \
  lab5-mcore-ProcCacheNetBase-or.t.v \
  lab5-mcore-ProcCacheNetBase-mul.t.v \
  lab5-mcore-ProcCacheNetBase-sw.t.v \
  lab5-mcore-ProcCacheNetBase-j.t.v \
  lab5-mcore-ProcCacheNetBase-jal.t.v \
  lab5-mcore-ProcCacheNetBase-jr.t.v \
  lab5-mcore-ProcCacheNetBase-xor.t.v \
  lab5-mcore-ProcCacheNetBase-nor.t.v \
  lab5-mcore-ProcCacheNetBase-vmh.t.v \

lab5_mcore_gen_alt_test_srcs = \
  lab5-mcore-ProcCacheNetAlt-mngr.t.v \
  lab5-mcore-ProcCacheNetAlt-addu.t.v \
  lab5-mcore-ProcCacheNetAlt-lw.t.v \
  lab5-mcore-ProcCacheNetAlt-bne.t.v \
  lab5-mcore-ProcCacheNetAlt-beq.t.v \
  lab5-mcore-ProcCacheNetAlt-bgtz.t.v \
  lab5-mcore-ProcCacheNetAlt-bgez.t.v \
  lab5-mcore-ProcCacheNetAlt-bltz.t.v \
  lab5-mcore-ProcCacheNetAlt-blez.t.v \
  lab5-mcore-ProcCacheNetAlt-addiu.t.v \
  lab5-mcore-ProcCacheNetAlt-ori.t.v \
  lab5-mcore-ProcCacheNetAlt-andi.t.v \
  lab5-mcore-ProcCacheNetAlt-xori.t.v \
  lab5-mcore-ProcCacheNetAlt-sra.t.v \
  lab5-mcore-ProcCacheNetAlt-srav.t.v \
  lab5-mcore-ProcCacheNetAlt-srl.t.v \
  lab5-mcore-ProcCacheNetAlt-srlv.t.v \
  lab5-mcore-ProcCacheNetAlt-sll.t.v \
  lab5-mcore-ProcCacheNetAlt-sllv.t.v \
  lab5-mcore-ProcCacheNetAlt-lui.t.v \
  lab5-mcore-ProcCacheNetAlt-subu.t.v \
  lab5-mcore-ProcCacheNetAlt-slt.t.v \
  lab5-mcore-ProcCacheNetAlt-sltu.t.v \
  lab5-mcore-ProcCacheNetAlt-slti.t.v \
  lab5-mcore-ProcCacheNetAlt-sltiu.t.v \
  lab5-mcore-ProcCacheNetAlt-and.t.v \
  lab5-mcore-ProcCacheNetAlt-or.t.v \
  lab5-mcore-ProcCacheNetAlt-mul.t.v \
  lab5-mcore-ProcCacheNetAlt-sw.t.v \
  lab5-mcore-ProcCacheNetAlt-j.t.v \
  lab5-mcore-ProcCacheNetAlt-jal.t.v \
  lab5-mcore-ProcCacheNetAlt-jr.t.v \
  lab5-mcore-ProcCacheNetAlt-xor.t.v \
  lab5-mcore-ProcCacheNetAlt-nor.t.v \
  lab5-mcore-ProcCacheNetAlt-vmh.t.v \

lab5_mcore_test_srcs = \
  lab5-mcore-mem-net-adapters.t.v \
  lab5-mcore-MemNet.t.v \
	$(lab5_mcore_gen_base_test_srcs) \
	$(lab5_mcore_gen_alt_test_srcs) \

lab5_mcore_sim_srcs = \
   lab5-mcore-sim-base.v \
   lab5-mcore-sim-alt.v \

#-------------------------------------------------------------------------
# Rules to generate test harnesses based on instructions
#-------------------------------------------------------------------------

$(lab5_mcore_gen_base_test_srcs) : lab5-mcore-ProcCacheNetBase-%.t.v \
	: lab5-mcore-ProcCacheNetBase.t.v lab5-mcore-test-cases-%.v \
	lab5-mcore-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(lab5_mcore_gen_alt_test_srcs) : lab5-mcore-ProcCacheNetAlt-%.t.v \
	: lab5-mcore-ProcCacheNetAlt.t.v lab5-mcore-test-cases-%.v \
	lab5-mcore-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@


#-------------------------------------------------------------------------
# Rules to run assembly tests
#-------------------------------------------------------------------------

# Directory of vmh files

test_vmh_dir = $(top_dir)/../test/build/vmh-cache

# List of implementations and inputs to test

#lab5_mcore_check_vmh_impls  = ProcCacheNetBase ProcCacheNetAlt
lab5_mcore_base_check_vmh_inputs = \
  cache-parcv1-addiu \
  cache-parcv1-addu \
  cache-parcv1-bne \
  cache-parcv1-jal \
  cache-parcv1-jr \
  cache-parcv1-lui \
  cache-parcv1-lw \
  cache-parcv1-ori \
  cache-parcv1-sw \
  cache-parcv2-and \
  cache-parcv2-andi \
  cache-parcv2-beq \
  cache-parcv2-bgez \
  cache-parcv2-bgtz \
  cache-parcv2-blez \
  cache-parcv2-bltz \
  cache-parcv2-j \
  cache-parcv2-jalr \
  cache-parcv2-mul \
  cache-parcv2-nor \
  cache-parcv2-or \
  cache-parcv2-sll \
  cache-parcv2-sllv \
  cache-parcv2-slt \
  cache-parcv2-slti \
  cache-parcv2-sltiu \
  cache-parcv2-sltu \
  cache-parcv2-sra \
  cache-parcv2-srav \
  cache-parcv2-srl \
  cache-parcv2-srlv \
  cache-parcv2-subu \
  cache-parcv2-xor \
  cache-parcv2-xori \

lab5_mcore_alt_check_vmh_inputs = \
  cache-mt-simple \
  cache-mt-addiu \
  cache-mt-addu \
  cache-mt-bne \
  cache-mt-jal \
  cache-mt-jr \
  cache-mt-lui \
  cache-mt-lw \
  cache-mt-ori \
  cache-mt-and \
  cache-mt-andi \
  cache-mt-beq \
  cache-mt-bgez \
  cache-mt-bgtz \
  cache-mt-blez \
  cache-mt-bltz \
  cache-mt-j \
  cache-mt-jalr \
  cache-mt-mul \
  cache-mt-nor \
  cache-mt-or \
  cache-mt-sll \
  cache-mt-sllv \
  cache-mt-slt \
  cache-mt-slti \
  cache-mt-sltiu \
  cache-mt-sltu \
  cache-mt-sra \
  cache-mt-srav \
  cache-mt-srl \
  cache-mt-srlv \
  cache-mt-subu \
  cache-mt-xor \
  cache-mt-xori \
  cache-mt-amo-add \
  cache-mt-amo-and \
  cache-mt-amo-or \

# Template used to create rules for each impl/input pair

define lab5_mcore_check_vmh_template

lab5_mcore_check_vmh_outs += lab5-mcore-$(1)-$(2)-vmh-test.out

lab5-mcore-$(1)-$(2)-vmh-test.out : lab5-mcore-$(1)-vmh-test
	./$$< +exe=$(test_vmh_dir)/$(2).vmh +verbose=2 | sed "s/$(1)/$(1)-$(2)/g" > $$@
endef

# Call template for each impl/input pair

#$(foreach impl,$(lab5_mcore_check_vmh_impls), \
#  $(foreach dataset,$(lab5_mcore_check_vmh_inputs), \
#    $(eval $(call lab5_mcore_check_vmh_template,$(impl),$(dataset)))))

$(foreach dataset,$(lab5_mcore_base_check_vmh_inputs), \
  $(eval $(call lab5_mcore_check_vmh_template,ProcCacheNetBase,$(dataset))))

$(foreach dataset,$(lab5_mcore_alt_check_vmh_inputs), \
  $(eval $(call lab5_mcore_check_vmh_template,ProcCacheNetAlt,$(dataset))))

# Generate summary and use the script to print the pass/fail

lab5-mcore-check-vmh-summary.out : $(lab5_mcore_check_vmh_outs)
	cat $^ > $@


lab5_mcore_junk += $(lab5_mcore_check_vmh_outs) \
	lab5-mcore-check-vmh-summary.out


lab5-mcore-check-vmh : lab5-mcore-check-vmh-summary.out
	$(scripts_dir)/test-summary --verbose $<

.PHONY : check-vmh-lab5-mcore

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# Directory of vmh files

eval_vmh_dir = $(top_dir)/../app/ubmark/build/vmh-cache

# List of implementations and inputs to evaluate

lab5_mcore_base_eval_inputs = \
  cache-ubmark-vvadd \
  cache-ubmark-cmplx-mult \
  cache-ubmark-bin-search \
  cache-ubmark-masked-filter \
  cache-ubmark-quicksort \

lab5_mcore_alt_eval_inputs = \
  cache-mtbmark-vvadd \
  cache-mtbmark-cmplx-mult \
  cache-mtbmark-bin-search \
  cache-mtbmark-masked-filter \
  cache-mtbmark-sort \


# Template used to create rules for each impl/input pair

define lab5_mcore_eval_template

lab5_mcore_eval_outs += lab5-mcore-sim-$(1)-$(2).out

lab5-mcore-sim-$(1)-$(2).out : lab5-mcore-sim-$(1) $(eval_vmh_dir)/$(2).vmh
	./$$< +exe=$(eval_vmh_dir)/$(2).vmh +stats | tee $$@

endef

$(foreach dataset,$(lab5_mcore_base_eval_inputs), \
  $(eval $(call lab5_mcore_eval_template,base,$(dataset))))

$(foreach dataset,$(lab5_mcore_alt_eval_inputs), \
  $(eval $(call lab5_mcore_eval_template,alt,$(dataset))))

lab5_mcore_junk += $(lab5_mcore_eval_outs)

# Grep all evaluation results

lab5-mcore-eval : $(lab5_mcore_eval_outs)
	@echo ""
	@echo "Verify:"
	@grep "\[ passed \]\|\[ FAILED \]" $^ | column -s ":=" -t
	@echo ""
	@echo "Num cycles:"
	@grep "\<num_cycles\>" $^ | column -s ":=" -t
	@echo ""


