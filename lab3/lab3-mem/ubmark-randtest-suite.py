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
    .format( addr, data )

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

#--------------------------------------------------------------------------------
# Random test 1:  Simple address patterns, single request type, with random data
#--------------------------------------------------------------------------------
# accesses for a[] in:
# for ( i = 0; i < 100; i++ )
#   result += a[i];

if sys.argv[1] == "rand_1":

  ref_mem = {}
  w = [0 for i in range(4)]

  # initialize memory with index
  base_addr = 0x1000
  for j in xrange(0,100,4):
    addr = base_addr + j * 4
    for i in range(4):	#set ref_mem
    	w[i] = random.randint(0, 0x1000)
    	ref_mem[j+i] = w[i]
    print_load_mem( addr, w[0], w[1], w[2], w[3] )

  # generate memory requests according to loop-1d pattern
  for j in xrange(100):
    addr = base_addr + j * 4
    print_cache_read( addr, ref_mem[j] )	#Check against rem_mem value

#--------------------------------------------------------------------------------
# Random test 2: Random address patterns, request types, and data
#--------------------------------------------------------------------------------
# Random address pattern here: make random memory reads in a fixed memory range,
#                              but make a specific access only up to 2 times

if sys.argv[1] == "rand_2":

  ref_mem = {}
  rep_mem = {}
  bit = 0
  temp_data = 0
  tmp = 0
  w = [0 for i in range(4)]

  # initialize memory with random data in cache-line address range 0x1000 - 0x1180
  base_addr = 0x1000
  for j in xrange(0,100,4):
    addr = base_addr + j * 4
    for i in range(4):  #set ref_mem
      w[i] = random.randint(0, 0xffffffff)
      ref_mem[j+i] = w[i]
      rep_mem[j+i] = 0        #Counts of accesses to this addresses
    print_load_mem( addr, w[0], w[1], w[2], w[3] )

  # generate random memory requests (writes or reads) a total of 100 times
  for i in xrange(100):
    #pick a random type of memory request (write or read)
    bit = random.randint(0, 1)
    #randomly pick an address by picking a random number in 0-100           #CHECK!!!!
    tmp = random.randint(1, 100) - 1  #Gives a number from 0-99
    addr = base_addr + tmp * 4
    while rep_mem[tmp] == 2:  #Don't refer to the same memory location more than twice
      tmp = random.randint(1, 100) - 1
      addr = base_addr + tmp * 4
    rep_mem[tmp] += 1        #Now that we have an addr, make sure to increment num accesses to it
    if bit == 0:
      print_cache_read(  addr, ref_mem[tmp] )  #Check against ref_mem value
    else:
      temp_data = random.randint(0, 0xffffffff)
      ref_mem[tmp] = temp_data    #update ref_mem
      print_cache_write( addr, temp_data)

#-------------------------------------------------------------------------
# Unrecognized dataset
#-------------------------------------------------------------------------

else:
  sys.stderr.write("unrecognized command line argument\n")
  exit(1)

exit(0)




