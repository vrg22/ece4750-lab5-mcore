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

# size: Use multiple of 2 to ensure stability of tests
size = 50
print "num_inputs =", size, ";"

in0 = []
in1 = []
out = []

#-------------------------------------------------------------------------
# small dataset
#-------------------------------------------------------------------------

# small numbers
if sys.argv[1] == "small":
  for i in xrange(size):

    a = random.randint(0,100)
    b = random.randint(0,100)

    in0.append( a & 0xffffffff )
    in1.append( b & 0xffffffff )
    out.append( (a * b) & 0xffffffff )

  print_dataset( in0, in1, out )


# Add code to generate other random datasets here

# large numbers
elif sys.argv[1] == "large":
  for i in xrange(size):

    a = random.randint(0x0000,0xffff)
    b = random.randint(0x0000,0xffff)

    in0.append( a )
    in1.append( b )
    out.append( a * b )

  print_dataset( in0, in1, out )

# low bits masked
elif sys.argv[1] == "lowmask":
  for i in xrange(size/2):

    a = random.randint(0x0000,0xffff)
    b = random.randint(0x0000,0xffff)

    a = a & 0xfff0
    b = b & 0xfff0

    in0.append( a )
    in1.append( b )
    out.append( a * b )

  for i in xrange(size/2):

    a = random.randint(0x0000,0xffff)
    b = random.randint(0x0000,0xffff)

    a = a & 0xff00
    b = b & 0xfff0

    in0.append( a )
    in1.append( b )
    out.append( a * b )

  print_dataset( in0, in1, out )

# middle bits masked
elif sys.argv[1] == "midmask":
  for i in xrange(size/2):

    a = random.randint(0x0000,0xffff)
    b = random.randint(0x0000,0xffff)

    a = a & 0xf0ff
    b = b & 0xff0f

    in0.append( a )
    in1.append( b )
    out.append( a * b )

  print_dataset( in0, in1, out )

  for i in xrange(size/2):

    a = random.randint(0x0000,0xffff)
    b = random.randint(0x0000,0xffff)

    a = a & 0xf00f
    b = b & 0xf00f

    in0.append( a )
    in1.append( b )
    out.append( a * b )

  print_dataset( in0, in1, out )


#-------------------------------------------------------------------------
# Unrecognized dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)

