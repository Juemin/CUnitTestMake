
#==============================================================================
#
# Setup google unit test
#


# --- Set google test installation path
GTEST_DIR   = $(BASE_DIR)/../../gtest

# --- Add include path
INC_PATH    += -I $(GTEST_DIR)/include

# --- Add gtest lib
DEP_LIB	    += $(GTEST_DIR)/make/gtest_main.a

# --- Add gtest link flag
LNKFLAGS    += -pthread

#-------------------------------------------------- 