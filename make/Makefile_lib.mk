## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#### Input ####
# SRC
# Define test source file
# Source files are defined at the entry Makefile

# Object files used to build lib only
ifndef LIB_OBJ
# Exclude those not belong to lib
ifndef TARGET
TARGET	:= $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Set target executable --- $(TARGET))
endif
ifndef EXE_OBJ
EXE_OBJ	:= $(addsuffix .o,$(TARGET))
$(info Set executable obj ----- $(EXE_OBJ))
endif
LIB_OBJ	:= $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),$(EXE_OBJ))
$(info Set lib source obj ----- $(LIB_OBJ))
endif
EXP_LIB_OBJ := $(addprefix $(abspath .),$(LIB_OBJ))

# Define lib for caller in different directories
# Get current dir's name to form lib name
ifndef EXP_LIB
EXP_LIB	:= $(call DEF_EXPORT_LIB,.,$(BD_DIR))
# This is lib name based on dir name
$(info Set lib .a ------------- $(EXP_LIB))
endif

# If have depend dirs, get the lib names from the dirnames and add to depend lib
ifdef DEP_DIR
add_lib := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p),$(BD_DIR)))
DEP_LIB += $(add_lib)
DEP_DIR =
$(info Set depend libs -------- $(DEP_LIB))
endif

#==============================================================================

# pull in dependency info for *existing* .o files
.build-lib  : $(EXP_LIB)

# Archieve all depend lib objects and object files into one archive
# Extract depend archive objects and re-archive with object files in current dir
$(EXP_LIB)  : $(LIB_OBJ) $(DEP_LIB)
	ar -Tcrs $@ $(LIB_OBJ)
	@for i in $(DEP_LIB); do \
	    depobj=`ar -t $$i`; \
	    echo $$depobj; \
	    ar -Tq $@ $$depobj; \
	done

# Build depend lib in a different dir
%_direxp.a  :
	@echo Build depend lib $@ - $(BD_DIR)
	$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-lib

.echo-libobj:
	@echo $(EXP_LIB_OBJ)

# remove compilation products
.clean	    ::
	rm -f $(EXP_LIB)

PHONY: .build-lib .echo-explib .echo-libobj .clean
