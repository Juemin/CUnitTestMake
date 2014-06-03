#==============================================================================
#
# Define base dir
BASE_DIR=../..

# User set variable options

# Define the build dir
# 
# --- Source file list
# SRC =
# --- Ignore files, excluded
# IGNORE	=

# --- Set target pathname
# Use default TARGET 

# --- Set included path used for compiling
INC_PATH    :=

# --- Compiler flag
CFLAGS      :=
CPPFLAGS    :=
CXXFLAGS    :=
LDFLAGS     :=

# --- Define depending libs' dirs
DEP_DIR	    := 

# --- Define external libs'
EXT_LIB	    :=

# --- Link flags
LNKFLAGS    :=

# --- Set google test installation path
# GTEST_DIR   = $(BASE_DIR)/../gtest

# --- Default build targets.
# .build-dep --- build object dependence files
# .build-obj --- build object files
# .build-lib --- build current dir's export lib
# .build-exe --- build executable
# .runtest   --- run all built executables
# .clean     --- clean up generated files
# distclean  --- Remove build dir and runtest dir
# default	:   .build-exe
default		: .build-lib
#

# Options:
# --- Do not make executable	: 
NO_MK_EXE = 1

ifndef BASE_DIR
$(error >>>>> Miss project BASE_DIR definition <<<<<)
endif
#
include $(BASE_DIR)/make/load_makefile.mk
