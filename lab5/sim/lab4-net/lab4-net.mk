#=========================================================================
# lab4-net Subpackage
#=========================================================================

lab4_net_deps = \
  vc \

lab4_net_srcs = \
  lab4-net-RingNetFL.v \
  lab4-net-RouterInputCtrl.v \
  lab4-net-RouterInputTerminalCtrl.v \
  lab4-net-RouterOutputCtrl.v \
  lab4-net-RouterBase.v \
  lab4-net-RingNetBase.v \
  lab4-net-RouterAlt.v \
  lab4-net-RingNetAlt.v \

lab4_net_test_srcs = \
  lab4-net-RingNetFL.t.v \
  lab4-net-RouterInputCtrl.t.v \
  lab4-net-RouterInputTerminalCtrl.t.v \
  lab4-net-RouterOutputCtrl.t.v \
  lab4-net-RouterBase.t.v \
  lab4-net-RingNetBase.t.v \
  lab4-net-RouterAlt.t.v \
  lab4-net-RingNetAlt.t.v \

lab4_net_sim_srcs = \
  lab4-net-sim-base.v \
  lab4-net-sim-alt.v \

lab4_net_pyv_srcs = \
  lab4-net-gen-input_urandom.py.v \

#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

lab4_net_srcs += \
  lab4-net-GreedyRouteCompute.v \
  lab4-net-AdaptiveRouteCompute.v \
  lab4-net-RouterAdaptiveInputTerminalCtrl.v \

lab4_net_test_srcs += \
  lab4-net-GreedyRouteCompute.t.v \
  lab4-net-AdaptiveRouteCompute.t.v \
  lab4-net-RouterAdaptiveInputTerminalCtrl.t.v \

lab4_net_pyv_srcs += \
  lab4-net-gen-input_tornado.py.v \

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

lab4_net_eval_impls  = base alt
lab4_net_eval_inputs = urandom \
                        partition2 \
                        partition4 \
                        tornado \
                        neighbor \
                        complement \
                        reverse \
                        rotation \

# Template used to create rules for each impl/input pair

define lab4_net_eval_template

lab4_net_eval_outs += lab4-net-sim-$(1)-$(2).out
lab4_net_eval_$(2)_outs += lab4-net-sim-$(1)-$(2).out

lab4-net-sim-$(1)-$(2).out : lab4-net-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

define lab4_net_eval_plot_template

lab4_net_eval_plots += lab4-net-$(1)-plot.png

lab4-net-$(1)-plot.png : lab4-net-gen-plot.py $$(lab4_net_eval_$(1)_outs)
	$(PYTHON) $$< -f $$@ $$(lab4_net_eval_$(1)_outs)

endef

# Call template for each impl/input pair

$(foreach impl,$(lab4_net_eval_impls), \
  $(foreach dataset,$(lab4_net_eval_inputs), \
    $(eval $(call lab4_net_eval_template,$(impl),$(dataset)))))

$(foreach dataset,$(lab4_net_eval_inputs), \
	$(eval $(call lab4_net_eval_plot_template,$(dataset))))

lab4_net_junk += $(lab4_net_eval_plots)

# Generate all of the plots

lab4-net-eval : $(lab4_net_eval_plots) $(lab4_net_eval_outs)
	@echo ""
	@echo "Zero load latency:"
	@grep zero_load_lat $(lab4_net_eval_outs) | column -s ":=*" -t
	@echo ""
	@echo "Injection rate that saturates the network:"
	@grep sat_inj_rate $(lab4_net_eval_outs) | column -s ":=*" -t
	@echo ""
	@echo "plots generated: $(lab4_net_eval_plots)"


#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

lab4_net_harness_conv = lab4-net-RouterBase.v \
  lab4-net-RouterBase.t.v \
  lab4-net-RingNetBase.v \

lab4-net-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab4-net \
    $(src_dir) \
    $(src_dir)/lab4-net/lab4-net-gen-harness-cfg
	cd ece4750-lab4-net/lab4-net/; \
	for i in $(lab4_net_harness_conv);  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Base/Alt/g" | \
			sed "s/BASE/ALT/g" > \
			`echo $$i | sed "s/Base/Alt/g"`; \
		done; \
	cd ../..; \
	tar czvf ece4750-lab4-net.tar.gz ece4750-lab4-net \

lab4-net-harness : lab4-net-harness

.PHONY: lab4-net-harness lab4-net-harness

lab4_net_junk += ece4750-lab4-net ece4750-lab4-net.tar.gz

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++
