#=========================================================================
# Configuration file for generating the lab harness
#=========================================================================

include_full_subpkgs = [
  "vc",
  "ex-basics",
  "ex-regincr",
  "ex-sorter",
  "ex-gcd",
]

include_partial_subpkgs = [
  "lab1-imul",
]

include_partial_subpkgs_full_files = [
  "lab1-imul/lab1-imul-msgs.v",
  "lab1-imul/lab1-imul-msgs.t.v",
  "lab1-imul/lab1-imul-IntMulFL.v",
  "lab1-imul/lab1-imul-IntMulFL.t.v",
  "lab1-imul/lab1-imul-IntMulBase.t.v",
  "lab1-imul/lab1-imul-IntMulAlt.t.v",
  "lab1-imul/lab1-imul-sim-base.v",
  "lab1-imul/lab1-imul-sim-alt.v",
]

include_partial_subpkgs_strip_files = [
  "lab1-imul/lab1-imul.mk",
  "lab1-imul/lab1-imul-gen-input.py",
  "lab1-imul/lab1-imul-IntMulBase.v",
  "lab1-imul/lab1-imul-IntMulAlt.v",
  "lab1-imul/lab1-imul-test-harness.v",
  "lab1-imul/lab1-imul-sim-harness.v",
]

