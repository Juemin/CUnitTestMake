#==============================================================================
#
# Define base dir
BASE_DIR= $(abspath ../../.)

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
CPPFLAGS    :=
CXXFLAGS    :=

# --- Define depending libs' dirs
#DEP_DIR	    := .
	
# --- Define external libs'
EXT_LIB	    :=

# --- Link flags
LNKFLAGS    :=

# --- Use gtest
#include $(BASE_DIR)/make/Makefile_gtest.mk

# --- Default build targets.
# .build-dep --- build object dependence files
# .build-obj --- build object files
# .build-lib --- build current dir's export lib
# .build-exe --- build executable
# .runtest   --- run all built executables
# .clean-all --- clean up
default	:   .build-lib
#

# Options:
# --- Do not make lib		: NO_MK_LIB = 1
# --- Do not make executable	: 
NO_MK_EXE = 1
include $(BASE_DIR)/make/load_makefile.mk
