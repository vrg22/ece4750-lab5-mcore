#=========================================================================
# lab3-mem Subpackage
#=========================================================================

#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

lab3_mem_deps = \
  vc \

lab3_mem_srcs = \
  lab3-mem-DecodeWben.v \
  lab3-mem-BlockingCacheFL.v \
  lab3-mem-BlockingCacheBaseDpath.v \
  lab3-mem-BlockingCacheBaseCtrl.v \
  lab3-mem-BlockingCacheBase.v \
  lab3-mem-BlockingCacheAltDpath.v \
  lab3-mem-BlockingCacheAltCtrl.v \
  lab3-mem-BlockingCacheAlt.v \

lab3_mem_test_srcs = \
  lab3-mem-DecodeWben.t.v \
  lab3-mem-BlockingCacheFL.t.v \
  lab3-mem-BlockingCacheBase.t.v \
  lab3-mem-BlockingCacheAlt.t.v \

lab3_mem_sim_srcs = \
  lab3-mem-sim-base.v \
  lab3-mem-sim-alt.v \

lab3_mem_pyv_srcs = \
  lab3-mem-gen-input_random-writeread.py.v \
  lab3-mem-gen-input_random.py.v \
  lab3-mem-gen-input_ustride.py.v \
  lab3-mem-gen-input_stride2.py.v \
  lab3-mem-gen-input_stride4.py.v \
  lab3-mem-gen-input_shared.py.v \
  lab3-mem-gen-input_ustride-shared.py.v \
  lab3-mem-gen-input_loop-1d.py.v \
  lab3-mem-gen-input_loop-2d.py.v \
  lab3-mem-gen-input_loop-3d.py.v \

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

lab3_mem_eval_impls  = base alt
lab3_mem_eval_inputs = loop-1d loop-2d loop-3d

# lab3_mem_eval_inputs = random ustride stride2 stride4 \
#												shared ustride-shared loop-1d loop-2d loop-3d

# Template used to create rules for each impl/input pair

define lab3_mem_eval_template

lab3_mem_eval_outs += lab3-mem-sim-$(1)-$(2).out

lab3-mem-sim-$(1)-$(2).out : lab3-mem-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(lab3_mem_eval_impls), \
  $(foreach dataset,$(lab3_mem_eval_inputs), \
    $(eval $(call lab3_mem_eval_template,$(impl),$(dataset)))))

# Grep all evaluation results

lab3-mem-eval : $(lab3_mem_eval_outs)
	@echo ""
	@echo "AMAL:"
	@grep amal $^ | column -s ":=" -t
	@echo ""


#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

lab3-mem-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab3-mem \
    $(src_dir) \
    $(src_dir)/lab3-mem/lab3-mem-gen-harness-cfg
	tar czvf ece4750-lab3-mem.tar.gz ece4750-lab3-mem \

.PHONY: lab3-mem-harness

lab3_mem_junk += ece4750-lab3-mem ece4750-lab3-mem.tar.gz


#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++

#+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++
#
# lab3_mem_deps = \
#   vc \
#
# lab3_mem_srcs = \
#   lab3-mem-BlockingCacheFL.v \
#   lab3-mem-BlockingCacheBaseDpath.v \
#   lab3-mem-BlockingCacheBaseCtrl.v \
#   lab3-mem-BlockingCacheBase.v \
#   lab3-mem-BlockingCacheAltDpath.v \
#   lab3-mem-BlockingCacheAltCtrl.v \
#   lab3-mem-BlockingCacheAlt.v \
#
# lab3_mem_test_srcs = \
#   lab3-mem-BlockingCacheFL.t.v \
#   lab3-mem-BlockingCacheBase.t.v \
#   lab3-mem-BlockingCacheAlt.t.v \
#
# lab3_mem_sim_srcs = \
#   lab3-mem-sim-base.v \
#   lab3-mem-sim-alt.v \
#
# lab3_mem_pyv_srcs = \
#   lab3-mem-gen-input_loop-1d.py.v \
#   lab3-mem-gen-input_loop-2d.py.v \
#   lab3-mem-gen-input_loop-3d.py.v \
#
# #-------------------------------------------------------------------------
# # Evaluation
# #-------------------------------------------------------------------------
#
# # List of implementations and inputs to evaluate
#
# lab3_mem_eval_impls  = base alt
# lab3_mem_eval_inputs = loop-1d loop-2d loop-3d
#
# # Template used to create rules for each impl/input pair
#
# define lab3_mem_eval_template
#
# lab3_mem_eval_outs += lab3-mem-sim-$(1)-$(2).out
#
# lab3-mem-sim-$(1)-$(2).out : lab3-mem-sim-$(1)
# 	./$$< +input=$(2) +stats | tee $$@
#
# endef
#
# # Call template for each impl/input pair
#
# $(foreach impl,$(lab3_mem_eval_impls), \
#   $(foreach dataset,$(lab3_mem_eval_inputs), \
#     $(eval $(call lab3_mem_eval_template,$(impl),$(dataset)))))
#
# # Grep all evaluation results
#
# lab3-mem-eval : $(lab3_mem_eval_outs)
# 	@echo ""
# 	@echo "AMAL:"
# 	@grep amal $^ | column -s ":=" -t
# 	@echo ""
#
#+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++
