## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#### Input ####
# SRC (optional)
#   List of files to compute theirs dependence. If not defined, using *.c and *.cpp
#

#### Output ####
#
################

# Define test source file
# Source files are defined in entry Makefile

# List of all object files, including lib and exe
ifndef OBJ
OBJ	:= $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),)
$(info Set object files ------- $(OBJ))
endif

# Dependences for each object files
ifndef DEP
DEP	:= $(OBJ:.o=.d)
$(info Set obj dependenc ------ $(DEP))
endif
#

##
# Get dependency info for *existing* .o files
-include $(DEP)

# If $(DEP) files do not exist, it will trigger a second-time build
# No deleting $(DEP) after they are created.

#==============================================================================

# Test generate dependence files
.build-obj: $(OBJ)

$(BD_DIR)/%.o	: $(BD_DIR)/%.d

$(BD_DIR)/%.o	: %.cpp
	$(GXX) -c $(CPPFLAGS) $(CXXFLAGS) $(INC_PATH) $(CFLAGS) $< -o $@

$(BD_DIR)/%.o	: %.c
	$(GCC) -c $(CPPFLAGS) $(INC_PATH) $(CFLAGS) $< -o $@

# remove compilation products
.clean		::
	rm -f $(OBJ)


.PHONY: .build-obj .build-exe .clean