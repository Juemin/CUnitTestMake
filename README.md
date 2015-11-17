CUnitTestMake
=============

Most of my C/C++ coding starts with creating makefile, and I don't want to
create, modify, and maintain these makefile scripts all the time. Therefore, I
created this project in an attempt to keep makefile scripting work to minimum.

In some cases, it may get a better organization of source files using
directory-tree structure, instead putting most of source code in one source
directory.  Source code logically related closely can be put in the same
directory.  An OO class hierarchical structure can use the same corresponding
directory-tree structure to store.

C/C++ source code files in the a director share the same is related and
therefore are compiling and linking options and flags, such as include search
path, linking option and libraries depending on.  Thus, we can apply same
options and flags in building source code in the same directory.

Since there are more than one source directories, we should allow source code in
one source code directory to call functions or reference variables in a
different source code directory.

--------------


Usage
==========================================

1) Each source directory contains an configure makefile.  You can copy a common
   template, Makefile.template to start with from the makefile module
   directory. 

2) All source directories are under the same BASE_DIR directory. 

3) In configure makefile in each source directory, set following variables:

      BASE_DIR  : root directory of project 
      MK_DIR    : makefile directory, like $(BASE_DIR)/make
      SRC       : all source file in the directory.  If not specified, we will 
                  use all .c, cc and .cpp files  
      IGNORE    : excluding files from SRC

      DEP_DIR   : depend directories, directories which source code in current
                  directory call or reference.  To use this feature, host OS
                  needs to have binutil AR 2.20 or above.  It uses thin
                  archive option to generate shared libraries.

      GTEST_DIR : if defined, used as google test installed directory.

4) Option variables

      BIN_ROOT  : if specified, we will store all generated files in a same
                  source code directory-tree structure under it.  If not, bin
                  directory is under its source directory (Default).
      DBG, DBG1 : makefile system debug output. 

5) Compile and link options and flags
      INC_PATH  :
      CFLAGS    :
      CPPFLAGS  :
      CXXFLAGS  :
      LDFLAGS   :
      LNKFLAGS  :
      EXT_LIB   : external libraries loaded in linking time.


4) List of some predefined target and short keys

      default   : build-exe, building all executables

      build-dep :
      dep       : build dependence rules if DEP_DIR is specified
   
      build-lib :
      lib       : build directory libraries in local and DEP_DIR directories.

      build-exe :
      exe       : build executables

      runtest   :
      run       : run all executables built from the current directory. Since
                  the makefile system is original used for unit testing, no
                  execution arguments are passed. 

     clean      : remove generated files from building and testing.

     distclean    : remove bin directory of local dir
     distclean-all: remove all bin directories under BASE_DIR

5) Some makefile modules are also available but under experiements.
   Makefile_tag.mk  : makefile module to build tag and cscope
   Makefile_sh.mk   : makefile module to run shell scripts




