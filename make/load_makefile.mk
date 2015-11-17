## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#==============================================================================
#
# Load Makefile modules
#
#==============================================================================

# Set shell
SHELL 		:= /bin/bash
# Set debug
DBG			:=
DBG1		:= 1
# Delete dependence rule and force it to be rebuilt in next make
DEL_LIB_DEP	:= 1


#-------------------------------------------------- 
# Set the project base dir, using relative dir
ifndef BASE_DIR
$(error >>>>> Miss project BASE_DIR definition <<<<<)
endif

ifeq ("$(wildcard $(BASE_DIR))","")
$(error >>>>> Cannot find base dir: $(BASE_DIR))
endif
BASE_PATH:= $(realpath $(BASE_DIR))
#-------------------------------------------------- 

$(if $(DBG),$(info Project base ----------- $(BASE_DIR)))
$(if $(DBG),$(info Makefile starts in ----- $(abspath .)))

#==============================================================================
# Set default goal if no target specified for make
#==============================================================================
ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS:= build-exe
default		: build-exe
endif

$(if $(DBG),$(info Make command goals ----- $(MAKECMDGOALS)))

#==============================================================================
# Define common makefile functions. Must be defined before using
#==============================================================================

#-------------------------------------------------------------
# GET_BIN_PATH: [source dir]
define GET_BIN_PATH
$(if $(BIN_ROOT),$(patsubst $(BASE_PATH)/%,$(BIN_ROOT)/%,$(abspath $(1))),$(1))
endef

#
define GET_SRC_PATH
$(if $(BIN_ROOT),$(patsubst $(BIN_ROOT)/%,$(BASE_PATH)/%,$(abspath $(1))),$(1))
endef

#-------------------------------------------------------------
# FIND_SOURCE_FILES: wildcat ignore
define FIND_SOURCE_FILES
$(filter-out $(2),$(strip $(wildcard $(1))))
endef

#-------------------------------------------------------------
# DEF_OBJ_FILES: build_dir,src_files,ignore_files
define DEF_OBJ_FILES
$(addprefix $(1)/,$(addsuffix .o,$(basename $(filter-out $(3),$(2)))))
endef

#-------------------------------------------------------------------
# DEF_TARGET_EXE: source [ source]
# Search all source find the one defining main(), return its executable path name
define DEF_EXE_NAME
$(basename $(strip $(shell $(MK_DIR)/find_main.pl $(1))))
endef

#-------------------------------------------------------------------
# Print list in sorted order
define PRINT_LIST
	echo ===================== $(1) =====================
	$(foreach t,$(call sort, $(2)), echo "$(t)";)
endef

define SORT_LIST
$(foreach t,$(call sort, $(1)),$(t)
                        )
endef

#-------------------------------------------------------------------
# Print help command for the given topic
define PRINT_HELP_TOPIC
	@echo
	@echo $(2)
	@echo Build the target ----------- make .build-$(1)
	@echo List all source objects ---- make .list-$(1)
	@echo Clean up ------------------- make .clean-$(1)
endef

#-------------------------------------------------------------------
# Print each argument in one line
define LIST_ARGS
	@echo $(1) | sed -e 's/\s-/ \\\n                             -/g'
endef

#==============================================================================
# Set default global variables
#==============================================================================

#--------------------------------------------------
# Set compiler
CC  	?= gcc
GCC 	?= gcc
GXX 	?= g++

# Set binutils ar
AR  	?= ar
# Set arch
ARCH	?= $(shell arch)
OS		?= $(shell uname | tr a-z A-Z)
#BIN_DIR	?= bin/$(OS)_$(ARCH)
UMAKE	:= $(MAKE) -f $(firstword $(MAKEFILE_LIST)) -s

#-------------------------------------------------------------------
# Add additional flags/options for compile
CFLAGS	    += -g
CPPFLAGS    +=
CXXFLAGS    += -std=c++11
#--------------------------------------------------
# The top dir name for binary code, including executable and objectfiles
BIN_DIR		:= bin

# Binary root dir can be current pwd, as default to set binary path to ./$(BIN_DIR)
# Or to separate binary from source dir, to put all object files under the 
# same project BASE_DIR in a common shared dir, like $(BASE_DIR)/all_bin/<src sub dir>,
# BIN_ROOT:=$(BASE_PATH)/all_bin

# Get current source subdir tree
# Make sure this make is executed in the same dir as its Makefile
CUR_PATH:= $(abspath .)

#--------------------------------------------------
# Expanding bin abspath
ifdef BIN_ROOT
BIN_ROOT:= $(abspath $(BIN_ROOT))
endif
$(if $(DBG),$(info Root binary path ------- $(BIN_ROOT)))

BIN_PATH:= $(call GET_BIN_PATH,$(CUR_PATH))/$(BIN_DIR)

$(if $(DBG),$(info Build obj and lib in --- $(BIN_PATH)))

#==============================================================================
# Loading Makefile modules based on the build goals
#==============================================================================

#-------------------------------------------------------------------
# Load cscope build module
ifneq ($(filter	cscope build-tag,$(MAKECMDGOALS)),)
$(if $(DBG),$(info Load cscope module ----- $(MK_DIR)/Makefile_tag.mk))
include $(MK_DIR)/Makefile_tag.mk
endif

#-------------------------------------------------------------------
# If we have more goals other than distclean, load other modules.
ifneq ($(if $(MAKECMDGOALS),$(filter-out distclean distclean-all, \
							$(MAKECMDGOALS)),1),)
#-------------------------------------------------------------------
# Making bin dir first
ifeq ("$(wildcard $(BIN_PATH))","")
$(shell mkdir -p $(BIN_PATH))
endif

#-------------------------------------------------------------------
# Load source object compile module
$(if $(DBG),$(info Load obj-build module -- $(MK_DIR)/Makefile_obj.mk))
include $(MK_DIR)/Makefile_obj.mk

#-------------------------------------------------------------------
# Load library module built from local dir and depending dirs
# Load source object compile module
$(if $(DBG),$(info Load library module ---- $(MK_DIR)/Makefile_lib.mk))
include $(MK_DIR)/Makefile_lib.mk

#-------------------------------------------------------------------
# Load google test framework library
ifdef GTEST_DIR
$(if $(DBG),$(info Load gtest module ------ $(MK_DIR)/Makefile_gtest.mk))
include $(MK_DIR)/Makefile_gtest.mk
endif

#-------------------------------------------------------------------
# Load executable link module
ifneq ($(EXE_SRC),)
$(if $(DBG),$(info Load exe-link module --- $(MK_DIR)/Makefile_exe.mk))
include $(MK_DIR)/Makefile_exe.mk
endif

#-------------------------------------------------------------------
# Load execution module
ifneq ($(TARGET) $(EXE_SRC),)
$(if $(DBG),$(info Load execution module -- $(MK_DIR)/Makefile_run.mk))
include $(MK_DIR)/Makefile_run.mk
endif

endif # End of loading modules other than used for distclean
#==============================================================================
# 
#==============================================================================

#----------------------------------------------
# distclean: remove build and runtest dirs recursively 
#
distclean	:
	$(if $(DBG),,@)rm -rf $(BIN_PATH)

distclean-all	: distclean
	$(if $(DBG),,@)for d in `find $(BASE_PATH) -mindepth 2 -type f -name Makefile | xargs -r dirname`; do\
	    $(UMAKE) -C $$d distclean; \
	done


.PHONY	: distclean disclean-all cscope build-tag
#----------------------------------------------



