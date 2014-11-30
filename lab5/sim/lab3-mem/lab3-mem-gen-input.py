#=========================================================================
# lab3-mem-gen-input
#=========================================================================
# Script to generate inputs for cache

import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

#-------------------------------------------------------------------------
# Helper Functions
#-------------------------------------------------------------------------

def print_load_mem( addr, word0, word1, word2, word3 ):
  print "load_mem( 32'h{:0>8x}, 128'h{:0>8x}_{:0>8x}_{:0>8x}_{:0>8x} );" \
    .format( addr, word3, word2, word1, word0 )

def print_cache_read( addr, data ):
  print "init_port( c_req_rd, 8'h00, 32'h{:0>8x}, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h{:0>8x} );" \
    .format( addr, data )

def print_cache_write( addr, data ):
  print "init_port( c_req_wr, 8'h00, 32'h{:0>8x}, 2'd0, 32'h{:0>8x}, c_resp_wr, 8'h00, 2'd0, 32'h???????? );" \
    .formt( addr, data )

if len( sys.argv ) < 2:
  print "please provide an argument"
  sys.exit()

#-------------------------------------------------------------------------
# loop-1d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 100; i++ )
#   result += a[i];

if sys.argv[1] == "loop-1d":

  # initialize memory with index
  base_addr = 0x1000
  for j in xrange(0,100,4):
    addr = base_addr + j * 4
    print_load_mem( addr, j, j+1, j+2, j+3 )

  # generate memory requests according to loop-1d pattern
  for j in xrange(100):
    addr = base_addr + j * 4
    print_cache_read( addr, j )

#-------------------------------------------------------------------------
# loop-2d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 100; j++ )
#     result += a[j];

elif sys.argv[1] == "loop-2d":

  # initialize memory with index
  base_addr = 0x1000
  for j in xrange(0,100,4):
    addr = base_addr + j * 4
    print_load_mem( addr, j, j+1, j+2, j+3 )

  # generate memory requests according to loop-2d pattern
  for i in xrange(5):
    for j in xrange(100):
      addr = base_addr + j * 4
      print_cache_read( addr, j )

#-------------------------------------------------------------------------
# loop-3d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 2; j++ )
#     for ( k = 0; k < 8; k++ )
#       result += a[j*64 + k*4];

elif sys.argv[1] == "loop-3d":

  # initialize memory with index
  base_addr = 0x1000
  for j in xrange(0,100,4):
    addr = base_addr + j * 4
    print_load_mem( addr, j, j+1, j+2, j+3 )

  # generate memory requests according to loop-3d pattern
  for i in xrange(5):
    for j in xrange(2):
      for k in xrange(8):
        addr = base_addr + (j*64 + k*4) * 4
        print_cache_read( addr, (addr - base_addr)/4 )

#-------------------------------------------------------------------------
# Unrecognized dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)

