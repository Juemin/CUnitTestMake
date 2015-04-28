## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#### Input ####
#
# SRC

#### Output ####
#
################

# Define test source file
# Source files are defined at the entry Makefile

# List of target exe in tests
ifndef TARGET
TARGET	:= $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Set target exe --------- $(TARGET))
endif

# List of executable object files. In test dir, LIB_OBJ should be empty
ifndef EXE_OBJ
EXE_OBJ	:= $(addsuffix .o,$(TARGET))
$(info Set executable obj ----- $(EXE_OBJ))
endif

# Define execution output files
PASS_TS	= $(addsuffix .pass.ts,$(TARGET))
TEST_OUT= $(addsuffix .output,$(TARGET))
$(info Test pass time stamp --- $(PASS_TS))

# Adding dynamic path
ifdef  ADD_LD_LIBRARY_PATH
	ld_path := $(LD_LIBRARY_PATH)$(ADD_LD_LIBRARY_PATH)
	export LD_LIBRARY_PATH = $(ld_path)
endif

.runtest    : $(PASS_TS)

.runtest-force :
	rm -f $(PASS_TS) $(TEST_OUT)
	$(MAKE) .runtest

$(BD_DIR)/%.pass.ts: $(BD_DIR)/%
#ifdef ADD_LD_LIBRARY_PATH
#	echo LD_LIBRARY_PATH=$(LD_LIBRARY_PATH)
#endif
	$(MK_DIR)/run_test.sh $^ $(BD_DIR) $@

.add_ld_lib_path:
	export LD_LIBRARY_PATH = $(LD_LIBRARY_PATH):$(RUN_DEP_LIB_PATH)


# remove test output and timestamp
.clean-run  :
	rm -f $(PASS_TS) $(TEST_OUT)

.clean	    :: .clean-run

#
PHONY: .runtest .clean .clean-run
