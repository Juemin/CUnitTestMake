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
TEST_DIR= $(SUB_TEST)/$(BD_DIR)
PASS_TS	= $(addprefix $(SUB_TEST)/, $(addsuffix .pass.ts,$(TARGET)))
TEST_OUT= $(addprefix $(SUB_TEST)/, $(addsuffix .output,$(TARGET)))
$(info Test pass time stamp --- $(PASS_TS))

.runtest    : $(PASS_TS)

$(TEST_DIR) :
	mkdir -p $(TEST_DIR)

$(TEST_DIR)/%.pass.ts: $(BD_DIR)/% | $(TEST_DIR)
	$(BASE_DIR)/make/run_test.sh $^ $(TEST_DIR) && touch $@

# remove test output and timestamp
.clean-run  :
	rm -f $(PASS_TS) $(TEST_OUT)

.clean	    :: .clean-run

#
PHONY: .runtest .clean .clean-run
