#=========================================================================
# lab3-mem-gen-input
#=========================================================================
# Script to generate inputs for cache

import random
import sys

# Use seed for reproducability

random.seed(0xdeadbeef)

max_address = 0xffff
cache = {}
cache_write_templ = "  init_port( c_req_wr, 8'h00, 32'h{:0>8x}, 2'd0, " + \
                               "32'h{:0>8x}, c_resp_wr, 8'h00, 2'd0, " + \
                               "32'h???????? );"

cache_read_templ = "  init_port( c_req_rd, 8'h00, 32'h{:0>8x}, 2'd0, " + \
                               "32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, " + \
                               "32'h{:0>8x} );"

load_mem_templ = "  load_mem( 32'h{:0>8x}, " + \
                              "128'h{:0>8x}_{:0>8x}_{:0>8x}_{:0>8x} );"

def print_header( dset ):
  # replace dashes in the task name with underscore
  print "task init_{};".format( dset.replace( "-", "_" ) )
  print "begin"

def print_footer():
  print "end"
  print "endtask"

def print_cache_write( addr, data ):
  print cache_write_templ.format( addr, data )

def print_cache_read( addr, data ):
  print cache_read_templ.format( addr, data )

def print_load_mem( addr, word0, word1, word2, word3 ):
  print load_mem_templ.format( addr, word3, word2, word1, word0 )

# prints a read function or a write function with some probability
# the data read/written is expected to be the same as the address
def cache_access( addr, read_prob=0.9 ):
  is_read = random.random() < read_prob
  data = addr
  if is_read:
    print_cache_read( addr, data )
  else:
    print_cache_write( addr, data )

if len( sys.argv ) < 2:
  print "please provide an argument"
  sys.exit()

#-------------------------------------------------------------------------
# loop-1d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 256; i++ )
#   result += a[i];

def gen_loop_1d():
  # initialize memory with data: each data word is just the address value
  base_addr = 0x5000
  for j in xrange(100):
    addr = base_addr + j * 16
    print_load_mem( addr, addr+0, addr+4, addr+8, addr+12 )

  # generate unit-stride loads to the cache
  for x in xrange( base_addr, base_addr + 256 * 4, 4):
    cache_access( x )

#-------------------------------------------------------------------------
# loop-2d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 100; j++ )
#     result += a[j];

def gen_loop_2d():
  # initialize memory with data: each data word is just the address value
  base_addr = 0x5000
  for j in xrange(100):
    addr = base_addr + j * 16
    print_load_mem( addr, addr+0, addr+4, addr+8, addr+12 )

  for i in xrange(5):
    for j in xrange(100):
      addr = base_addr + j * 4
      cache_access( addr )

#-------------------------------------------------------------------------
# loop-3d dataset
#-------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 5; i++ )
#   for ( j = 0; j < 2; j++ )
#     for ( k = 0; k < 8; k++ )
#       result += a[j*64 + k*4];

def gen_loop_3d( read_prob=0.9 ):
  # initialize memory with data: each data word is just the address value
  base_addr = 0x5000
  for j in xrange(100):
    addr = base_addr + j * 16
    print_load_mem( addr, addr+0, addr+4, addr+8, addr+12 )

  for i in xrange(5):
    for j in xrange(2):
      for k in xrange(8):
        addr = base_addr + (j*64 + k*4) * 4
        cache_access( addr, read_prob )


print_header( sys.argv[1] )

if sys.argv[1] == "loop-1d":
  gen_loop_1d()

elif sys.argv[1] == "loop-2d":
  gen_loop_2d()

elif sys.argv[1] == "loop-3d":
  gen_loop_3d()

print_footer()
