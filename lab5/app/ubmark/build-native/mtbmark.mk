#=========================================================================
# Modular C++ Build System Subproject Makefile Fragment
#=========================================================================
# Please read the documenation in 'mcppbs-uguide.txt' for more details
# on how the Modular C++ Build System works.

mtbmark_intdeps  = 
mtbmark_cppflags = -I../mtbmark 
mtbmark_ldflags  = 
mtbmark_libs     = -lmtbmark 

mtbmark_hdrs = \
  mtbmark.h \

mtbmark_srcs = \

mtbmark_install_prog_srcs = \
  mtbmark-vvadd.c \
  mtbmark-cmplx-mult.c \
  mtbmark-bin-search.c \
  mtbmark-masked-filter.c \
  mtbmark-sort.c \

