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

#==============================================================================
#
.build-exe  : .build-lib | $(TARGET)

$(BD_DIR)/% : $(BD_DIR)/%.o $(EXP_LIB) $(EXT_LIB)
	@echo Link executable $@
	$(GXX) -g $(LDFLAGS) $^ -o $@ $(LNKFLAGS)

# Preserve build lib, no deletion
# Depend libs are intermediate files which will be deleted if not 
# declare as .PRECIOUS or .SECONDARY
#.PRECIOUS   : $(DEP_LIB)

.clean	    ::
	rm -f $(TARGET)

#
PHONY: .build-exe .clean
