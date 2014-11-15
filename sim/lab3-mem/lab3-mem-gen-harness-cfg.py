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
  "lab3-mem",
]

include_partial_subpkgs_full_files = [
  "lab3-mem/lab3-mem-BlockingCacheFL.v",
  "lab3-mem/lab3-mem-BlockingCacheFL.t.v",
  "lab3-mem/lab3-mem-BlockingCacheBase.t.v",
  "lab3-mem/lab3-mem-BlockingCacheAlt.t.v",
  "lab3-mem/lab3-mem-sim-base.v",
  "lab3-mem/lab3-mem-sim-alt.v",
]

include_partial_subpkgs_strip_files = [
  "lab3-mem/lab3-mem.mk",
  "lab3-mem/lab3-mem-gen-input.py",
  "lab3-mem/lab3-mem-sim-harness.v",
  "lab3-mem/lab3-mem-test-harness.v",
  "lab3-mem/lab3-mem-BlockingCacheBase.v",
  "lab3-mem/lab3-mem-BlockingCacheBaseCtrl.v",
  "lab3-mem/lab3-mem-BlockingCacheBaseDpath.v",
  "lab3-mem/lab3-mem-BlockingCacheAlt.v",
  "lab3-mem/lab3-mem-BlockingCacheAltCtrl.v",
  "lab3-mem/lab3-mem-BlockingCacheAltDpath.v",
]

