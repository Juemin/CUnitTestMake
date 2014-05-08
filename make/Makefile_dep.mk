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

# CC Compiler Flags
#CCFLAGS	?= $(CPPFLAGS) $(CXXFLAGS) 
# Add other include path commonly shared by all dirs
# like, INC_PATH  += -I $(BASE_DIR)/../../gtest/include

# Define test source file
# Source files are defined at the entry Makefile

# Define object files from all source files
OBJ	?= $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),)
# Define object dependence files for all object files
DEP	?= $(OBJ:.o=.d)
#
$(info Source obj dependences - $(DEP))

#==============================================================================

# Build all dependence files in current directory
.build-dep  : $(DEP)

# Pre-requirement
$(DEP)	: | $(BD_DIR)

$(BD_DIR)   :
	mkdir -p $@

$(BD_DIR)/%.d	: %.cpp | $(BD_DIR)
	$(call COMPILE_DEPENDENCE,$<,$@,$(BD_DIR)/$*.o)

$(BD_DIR)/%.d	: %.c   | $(BD_DIR)
	$(call COMPILE_DEPENDENCE,$<,$@,$(BD_DIR)/$*.o)

# No remove depend for .clean-all, after obj depend files are created
# .d file will be updated when only .c / .cpp source files are changed
# Force to clean dependence files, only in very few extreme cases
.clean-depend  ::
	rm -f $(DEP)

.PHONY: .build-depend


# COMPILE_DEPENDENCE: src target
# Only preprocessing, no object file is created.
#
# GCC preprocessing options:
# -E  : Only preprocessing
# -M  : for make describing the dependencies of the main source file
# -MM : no header files that are found in system header directories
# -MF file : specify file to write dependences to
# -MG : assumes missing header files are generated files and adds them to the 
#        dependency list without raising an error.
# -MP : add a phony target for each dependency other than the main file
# -MD : equal to -M -MF file without -E
# -MMD: equal to -MD, no system headers
# -MT target: change target rule in dependences

define COMPILE_DEPENDENCE
@echo create dependence file for $(1)
$(GCC) $(CPPFLAGS) -c -E -M -MT $(3) -MM -MP -MF $(2) $(INC_PATH) $(1)
endef

#@mv -f $(3) $(3).tmp
#@sed -e 's|.*:|$(2):|' < $(3).tmp > $(3)
#@sed -e 's/.*://' -e 's/\\$$//' < $(3).tmp | fmt -1 | \
#  sed -e 's/^ *//' -e 's/$$/:/' >> $(3)
#@rm -f $(3).tmp
