## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#==============================================================================
#
# Module to run executables
#
#==============================================================================

#==============================================================================
# Defining variables
#==============================================================================

# Add script tests output
tgt_path	:=
ifneq ($(TARGET),)
tgt_path	:= $(addprefix $(BIN_PATH)/,$(TARGET))
endif

# Define execution output files
PASS_TS		:= $(addsuffix .pass.ts,$(EXE_PATH) $(tgt_path))
TEST_OUT	:= $(addsuffix .output,$(EXE_PATH) $(tgt_path))

#
$(if $(DBG),$(info Test pass time stamp --- $(call SORT_LIST,$(PASS_TS))))

#-------------------------------------------------------------------
# Adding dynamic path
ifdef  ADD_LD_LIBRARY_PATH
	export LD_LIBRARY_PATH += $(ADD_LD_LIBRARY_PATH)
endif

#==============================================================================
# Loading Makefile modules based on the build goals
#==============================================================================

#-------------------------------------------------------------------
# Short keys 
run runtest	: $(PASS_TS)
run-force	: runtest-force

#-------------------------------------------------------------------
runtest-force :
	$(if $(DBG),@echo ======================== Force to run tests)
	$(if $(DBG),,@)rm -f $(PASS_TS) $(TEST_OUT)
	$(if $(DBG),,@)$(UMAKE) runtest
	$(if $(DBG),@echo ======================== Done runtest-force)

# Built-executable run
$(BIN_PATH)/%.pass.ts: $(BIN_PATH)/%
	$(if $(DBG),,@)$(MK_DIR)/run_test.sh $^ $(BIN_PATH) $@

#-------------------------------------------------------------------
# Shell script run
$(BIN_PATH)/%.pass.ts: % | $(BIN_PATH)
	$(if $(DBG),,@)$(MK_DIR)/run_test.sh $< $(BIN_PATH) $@

.add_ld_lib_path:
	export LD_LIBRARY_PATH = $(LD_LIBRARY_PATH):$(RUN_DEP_LIB_PATH)

#-------------------------------------------------------------------
.list-target:
	@$(call PRINT_LIST,Executable target,$(EXE_PATH) $(TARGET))

.list-ts	:
	@$(call PRINT_LIST,Run time stamps,$(PASS_TS))

help list	:: .list-target .list-ts

#-------------------------------------------------------------------
# remove test output and timestamp
.clean-run  :
	$(if $(DBG),,@)rm -f $(PASS_TS) $(TEST_OUT)

clean	    :: .clean-run

#-------------------------------------------------------------------
#
.PHONY		: run runtest runtest-force clean list help \
			 .list-target .list-ts .clean-run
