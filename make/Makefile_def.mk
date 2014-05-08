## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

# macros
CC  ?= gcc
GCC ?= gcc
GXX ?= g++
AR  ?= ar


# Define test source file
#===============================
# FIND_SOURCE_FILES: wildcat ignore
define FIND_SOURCE_FILES
$(strip $(filter-out $(2),$(wildcard $(1))))
endef

#===============================
# DEF_OBJ_FILES: build_dir,src_files,ignore_files
define DEF_OBJ_FILES
$(filter-out $(3),$(addprefix $(1)/,$(addsuffix .o,$(basename $(2)))))
endef

#===============================
# DEF_DEP_FILES: build_dir,src_files,ignore_files
define DEF_DEP_FILES
$(filter-out $(3),$(addprefix $(1)/,$(addsuffix .d,$(basename $(2)))))
endef


#===============================
# DEF_EXPORT_LIB: lib_dir,build_dir
# Define the lib name exported from the given dir
define DEF_EXPORT_LIB
$(1)/$(2)/lib_$(notdir $(realpath $(1)))_direxp.a
endef
#

#===============================
# GET_LIB_DIR: lib_file,build_dir
# Reverse of DEF_EXPORT_LIB, retrieve dir of the exported lib from lib path
define GET_LIB_DIR
$(patsubst %/$(2)/,%,$(dir $(1)))
endef

#===============================
# DEF_TARGET_EXE: source [ source]
# Search all source find the one defining main(), return its executable pathname
define DEF_TARGET_EXE
$(addprefix $(1)/,$(basename $(strip $(shell $(BASE_DIR)/make/find_main.pl $(2)))))
endef

