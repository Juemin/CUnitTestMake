#==============================================================================
#
# Load Makefile definitions and rules : build and run tests
#

#-------------------------------------------------- 
# Set the project base dir, using relative dir
ifndef BASE_DIR
$(error >>>>> Miss project BASE_DIR definition <<<<<)
endif

ifndef MK_DIR
$(error >>>>> Miss CUnitTest Maefile dir definition <<<<<)
endif

#
$(info Project base ----------- $(BASE_DIR))
$(info Makefile starts in ----- $(abspath .))

#--------------------------------------------------
# Set the build dir. used to store all object, dependence and executab
# This is global macro for all dirs
ARCH	?= $(shell arch)
OS	?= $(shell uname | tr a-z A-Z)
BD_DIR  ?= build/$(OS)$(ARCH)
#
$(info Build obj and lib in --- $(BD_DIR))

# test dir
SUB_TEST:= runtest


#------------------------------------------------
# Shared definitions in all makefiles
include $(MK_DIR)/Makefile_def.mk

#------------------------------------------------
# Define all source files in current directory
# Source files, and filter out non-test source files
# IGNORE	=
# Optional
ifndef SRC
SRC  = $(call FIND_SOURCE_FILES,*.cpp,$(IGNORE))
SRC += $(call FIND_SOURCE_FILES,*.c,$(IGNORE))
endif
#
$(info Source files ----------- $(SRC))

#------------------------------------------------ 
# Define target executable in build dir
TARGET	?= $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Target exe files ------- $(TARGET))

# Define target and object files
# LIB_OBJ	    =
# EXE_OBJ	    = $(addsuffix .o $(TARGET))
#

# Include path in building, required by gtest
# INC_PATH    = -I $(BASE_DIR)/../../gtest/include
# Compiling flags
CFLAGS	    += -g
CPPFLAGS    +=
CXXFLAGS    += -std=c++11

# Define target and object files
# Executable target name
# Two types of object files
# 1) Contains main() to build target executable
EXE_OBJ	:= $(addsuffix .o,$(TARGET))
# 2) Used in building lib
LIB_OBJ	:= $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),$(EXE_OBJ))

#=======================================================


#=======================================================
ifeq ($(findstring distclean,$(MAKECMDGOALS)),)
# Not distclean related build

# Add include path option for compilation
ifdef INC_PATH
INC_OPT += $(addprefix -I ,$(INC_PATH))
endif

# Load make dependence file
include $(MK_DIR)/Makefile_dep.mk

# Load make object rules 
include $(MK_DIR)/Makefile_obj.mk

# Load google c/c++ unit test settings
ifdef GTEST_DIR
include $(MK_DIR)/Makefile_gtest.mk
endif

# Load rules to build lib
include $(MK_DIR)/Makefile_lib.mk

# No make executable and no loading Makefile_run.mk
ifndef NO_MK_EXE
include $(MK_DIR)/Makefile_exe.mk

ifneq ($(or $(findstring .runtest,$(MAKECMDGOALS)),\
	    $(findstring .clean,$(MAKECMDGOALS))),)
include $(MK_DIR)/Makefile_run.mk

endif
endif

#----------------------------------------------
else

# distclean: remove build and runtest dirs recursively 
#
distclean	:
	rm -rf $(BD_DIR) $(SUB_TEST)

.distclean-all	: distclean
	@for d in `find -mindepth 2 -type f -name Makefile | xargs -r dirname`; do\
	    $(MAKE) -C $$d distclean; \
	done

.distclean-rm-build-test:
	rm -rf build $(SUB_TEST)

.distclean-rm-all: .distclean-rm-build-test
	@for d in `find -mindepth 2 -type f -name Makefile | xargs -r dirname`; do\
	    $(MAKE) -C $$d .distclean-rm-build-test; \
	done

.PHONY	: distclean .disclean-all .distclean-rm-all .distclean-rm-build-test
#----------------------------------------------
endif
