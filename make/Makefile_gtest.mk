
#==============================================================================
#
# Setup google unit test
#


ifndef GTEST_DIR
$(error >>>>> missing GTEST_DIR <<<<<<)
endif

# --- Add include path
INC_OPT    += -I $(GTEST_DIR)/include

# --- Add gtest lib
#GTEST_LIB	= $(GTEST_DIR)/make/gtest_main.a
EXT_LIB		+= $(GTEST_DIR)/make/gtest_main.a

# --- Add gtest link flag
LNKFLAGS    += -pthread

#--------------------------------------------------
