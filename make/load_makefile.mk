#==============================================================================
#
# Load Makefile definitions and rules : build and run tests
#

#-------------------------------------------------- 
# Set the project base dir, using relative dir
ifndef BASE_DIR
$(error >>>>> Miss project BASE_DIR definition <<<<<)
endif
#
$(info Project base ----------- $(BASE_DIR))
$(info Makefile starts in ----- $(abspath .))

#--------------------------------------------------
# Set the build dir. used to store all object, dependence and executab
# This is global macro for all dirs
ARCH	:= $(shell arch)
OS	:= $(shell uname)
BD_DIR  := build/Debug/$(OS)_$(ARCH)
#
$(info Build obj and lib in --- $(BD_DIR))

# test dir
SUB_TEST:= runtest


#------------------------------------------------
# Shared definitions in all makefiles
include $(BASE_DIR)/make/Makefile_def.mk

#------------------------------------------------
# Define all source files in current directory
# Source files, and filter out non-test source files
# EIGNORE	=
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
ifeq ($(findstring distclean,$(MAKECMDGOALS)),)

#-----------------------------------------------
# Load make dependence file
include $(BASE_DIR)/make/Makefile_dep.mk

# Load make object rules 
include $(BASE_DIR)/make/Makefile_obj.mk

# Load google c/c++ unit test settings
ifdef GTEST_DIR
include $(BASE_DIR)/make/Makefile_gtest.mk
endif

# No make lib, pure test dir
ifndef NO_MK_LIB
include $(BASE_DIR)/make/Makefile_lib.mk
endif

# No make executable and no loading Makefile_run.mk
ifndef NO_MK_EXE
include $(BASE_DIR)/make/Makefile_exe.mk

ifneq ($(or $(findstring .runtest,$(MAKECMDGOALS)),\
	    $(findstring .clean,$(MAKECMDGOALS))),)
include $(BASE_DIR)/make/Makefile_run.mk

endif
endif

#----------------------------------------------
else

# distclean: remove build and runtest dirs recursively 
#
distclean	:
	rm -rf $(BD_DIR) $(SUB_TEST)

distclean-all	: distclean
	@for d in `find -mindepth 2 -type f -name Makefile | xargs -r dirname`; do\
	    $(MAKE) -C $$d distclean; \
	done

.PHONY	: distclean disclean-all
#----------------------------------------------
endif
#	alldirs=
