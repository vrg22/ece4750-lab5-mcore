#=========================================================================
# plab1-imul-input-gen
#=========================================================================
# Script to generate inputs for integer multiplier unit.

import fractions
import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------

def print_dataset( in0, in1, out ):

  for i in xrange(len(in0)):

    print "init( {:0>2}, 32'h{:0>8x}, 32'h{:0>8x}, 32'h{:0>8x} );" \
      .format( i, in0[i], in1[i], out[i] )

#-------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------

size = 50
print "num_inputs =", size, ";"

in0 = []
in1 = []
out = []

#-------------------------------------------------------------------------
# small dataset
#-------------------------------------------------------------------------

if sys.argv[1] == "small":
  for i in xrange(size):

    a = random.randint(0,100)
    b = random.randint(0,100)

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )

# Add code to generate other random datasets here

#-------------------------------------------------------------------------
# Unrecognized dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)

