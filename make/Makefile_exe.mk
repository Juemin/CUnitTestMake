## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#### Input ####
# SRC (optional)
#   List of files to compute theirs dependence. If not defined, using *.c and *.cpp
#

ifndef BASE_DIR
$(error >>>>> missing BASE_DIR <<<<<<)
endif

#### Output ####
#
################

# Define test source file
# Source files are defined at the entry Makefile


# List of target exe in tests
ifndef TARGET
TARGET	    := $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Set target executable --- $(TARGET))
endif

# List of executable/target object files, no lib objects
ifndef EXE_OBJ
EXE_OBJ	    := $(addsuffix .o,$(TARGET))
$(info Set target exe obj ----- $(EXE_OBJ))
endif

## Rational ##
# When building tests, we don't need lib object from the same dir.
# In most cases, functions in lib objects are called from sub-dir or other dirs
##############

add_lib	:=
ifdef EXP_LIB
add_lib	:= $(EXP_LIB)
endif

# If have depend dirs, get the lib names from the dirnames and add to depend lib
ifdef DEP_DIR
add_lib := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p),$(BD_DIR)))
endif


ifdef DEP_LIB
add_lib += $(strip $(DEP_LIB))
endif


# link time option flags, required by gtest
#LNKFLAGS +=

#==============================================================================
#
.build-exe  : .build-lib | $(TARGET)

$(BD_DIR)/% : $(BD_DIR)/%.o $(add_lib) $(EXT_LIB)
	@echo Link executable $@
	$(GXX) -g $(LDFLAGS) $^ -o $@ $(LNKFLAGS)

# Preserve build lib, no deletion
# Depend libs are intermediate files which will be deleted if not 
# declare as .PRECIOUS or .SECONDARY
.PRECIOUS   : $(DEP_LIB)

.clean	    ::
	rm -f $(TARGET)

#
PHONY: .build-exe .clean
