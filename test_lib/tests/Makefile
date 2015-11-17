#==============================================================================
#
# Define base dir
BASE_DIR:= ../..
MK_DIR	:= $(BASE_DIR)/make
DBG	:= 1

# User set variable options
TARGET	:= run_test.sh
# Define the build dir
# 
# --- Source file list
# SRC =
# --- Ignore files, excluded
# IGNORE	=

# --- Load google test module
LOAD_GTEST	:= 1
GTEST_DIR	:= $(BASE_DIR)/../gtest
# --- Set included path used for compiling
INC_PATH    :=

# --- Compiler flag
CFLAGS      :=
CPPFLAGS    :=
CXXFLAGS    :=
LDFLAGS     :=

# --- Define depending libs' dirs
DEP_DIR	    := ..

# --- Define external libs'
EXT_LIB	    :=

# --- Link flags
LNKFLAGS    :=

ifdef EXT_LIB
$(foreach f,$(EXT_LIB), $(if $(wildcard $(f)),,$(error Cannot find external lib:$(f))))
endif
# --- Set google test installation path
# GTEST_DIR   = $(BASE_DIR)/../gtest

# --- Default build targets.
# build-dep --- build object dependence files
# build-obj --- build object files
# build-lib --- build current dir's export lib
# build-exe --- build executable
# run       --- run all built executables
# clean     --- clean up generated files
# distclean  --- Remove build dir and runtest dir
default	    : build-exe
#

# Options:
# --- Do not make executable	: NO_MK_EXE = 1

ifndef BASE_DIR
$(error >>>>> Miss project BASE_DIR definition <<<<<)
endif
#
include $(BASE_DIR)/make/load_makefile.mk
