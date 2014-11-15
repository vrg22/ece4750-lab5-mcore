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
  "lab4-net",
]

include_partial_subpkgs_full_files = [
  "lab4-net/lab4-net-RingNetFL.v",
  "lab4-net/lab4-net-RingNetFL.t.v",
  "lab4-net/lab4-net-RingNetBase.v",
  "lab4-net/lab4-net-RingNetBase.t.v",
  "lab4-net/lab4-net-RingNetAlt.t.v",
  "lab4-net/lab4-net-sim-alt.v",
  "lab4-net/lab4-net-sim-base.v",
  "lab4-net/lab4-net-gen-plot.py",
]

include_partial_subpkgs_strip_files = [
  "lab4-net/lab4-net.mk",
  "lab4-net/lab4-net-gen-input.py",
  "lab4-net/lab4-net-test-harness.v",
  "lab4-net/lab4-net-sim-harness.v",
  "lab4-net/lab4-net-RouterBase.v",
  "lab4-net/lab4-net-RouterBase.t.v",
  "lab4-net/lab4-net-RouterInputCtrl.v",
  "lab4-net/lab4-net-RouterInputCtrl.t.v",
  "lab4-net/lab4-net-RouterOutputCtrl.v",
  "lab4-net/lab4-net-RouterOutputCtrl.t.v",
  "lab4-net/lab4-net-RouterInputTerminalCtrl.v",
  "lab4-net/lab4-net-RouterInputTerminalCtrl.t.v",
]

