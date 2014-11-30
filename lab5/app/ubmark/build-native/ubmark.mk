#=========================================================================
# Modular C++ Build System Subproject Makefile Fragment
#=========================================================================
# Please read the documenation in 'mcppbs-uguide.txt' for more details
# on how the Modular C++ Build System works.

ubmark_intdeps  = 
ubmark_cppflags = -I../ubmark 
ubmark_ldflags  = 
ubmark_libs     = -lubmark 

ubmark_hdrs = \
  ubmark.h \

ubmark_srcs = \

ubmark_install_prog_srcs = \
  ubmark-vvadd.c \
  ubmark-cmplx-mult.c \
  ubmark-bin-search.c \
  ubmark-masked-filter.c \
  ubmark-quicksort.c \
