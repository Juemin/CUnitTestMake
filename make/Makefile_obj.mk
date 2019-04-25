## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#==============================================================================
#
# Compile source to object files
#
#==============================================================================

#==============================================================================
# Function defintions
#==============================================================================

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
$(GCC) $(CPPFLAGS) -c -E -M -MT $(3) -MM -MP -MF $(2) $(INC_OPT) $(1)
endef

#==============================================================================
# Defining variables
#==============================================================================

#------------------------------------------------
# Define all source files in current directory
# Source files, and filter out non-test source files
# IGNORE	=
# Optional
ifndef SRC
SRC  := $(call FIND_SOURCE_FILES,*.cpp,$(IGNORE))
SRC  += $(call FIND_SOURCE_FILES,*.cc,$(IGNORE))
SRC  += $(call FIND_SOURCE_FILES,*.c,$(IGNORE))
endif
#
$(if $(DBG),$(info Source files ----------- $(call SORT_LIST,$(SRC))))

#-------------------------------------------------------------
# List of all object files, including lib and exe
OBJ	?= $(call DEF_OBJ_FILES,$(BIN_PATH),$(SRC),)
$(if $(DBG),$(info Set object files ------- $(call SORT_LIST,$(OBJ))))

#-------------------------------------------------------------
# Add include path option for compilation
ifneq ($(INC_PATH) $(DEP_DIR) $(imp_inc_path),)
INC_OPT += $(addprefix -I ,$(INC_PATH) $(DEP_DIR) $(imp_inc_path))
endif

#-------------------------------------------------------------
# Set header dependences for each object files
DEP	?= $(OBJ:.o=.d)
$(if $(DBG),$(info Set obj dependence ------ $(call SORT_LIST,$(DEP))))
#

#-------------------------------------------------------------
CFLAGS += $(VAR_DEF)

#==============================================================================
# Load header dependence build rules
#==============================================================================
# No need to loading the header dependence if we building lib dependence rule
ifneq ($(filter-out build-dep build-dep-rule clean, $(MAKECMDGOALS)),)
$(if $(DEB),$(info Load header-dep rules -- $(DEP)))
-include $(DEP)
endif

#==============================================================================
# Define header dependence build rules
#==============================================================================

.build-src-dep  : $(DEP)

# Pre-requirement
$(DEP)	: | $(BIN_PATH)

$(BIN_PATH)   :
	$(if $(DBG),,@)mkdir -p $@

$(BIN_PATH)/%.d	: %.c
$(BIN_PATH)/%.d	: %.cc
$(BIN_PATH)/%.d	: %.cpp
	$(GCC) $(CPPFLAGS) -c -E -M -MT $(BIN_PATH)/$*.o -MM -MP -MF $@ $(INC_OPT) $<

#$(call COMPILE_DEPENDENCE,$<,$@,$(BIN_PATH)/$*.o)

#	$(call COMPILE_DEPENDENCE,$<,$@,$(BIN_PATH)/$*.o)

#$(BIN_PATH)/%.d	: %.c
#	$(call COMPILE_DEPENDENCE,$<,$@,$(BIN_PATH)/$*.o)


#==============================================================================
# Define object build rules
#==============================================================================
# Test generate dependence files
build-obj		: $(OBJ)

$(BIN_PATH)/%.o	: $(BIN_PATH)/%.d

$(BIN_PATH)/%.o	: %.cpp
	$(GXX) -c $(CPPFLAGS) $(CXXFLAGS) $(INC_OPT) $(CFLAGS) $< -o $@

$(BIN_PATH)/%.o	: %.c
	$(GCC) -c $(CPPFLAGS) $(INC_OPT) $(CFLAGS) $< -o $@

#==============================================================================
# List and help action rules
#==============================================================================

.list-src	:
	@$(call PRINT_LIST,Source files,$(SRC))

.list-obj	:
	@$(call PRINT_LIST,Object files,$(OBJ))

#-----------------------------------------
.list-inc	:
	@echo    "Compile-time include path -- "
	@echo -n "                             "
	@$(call LIST_ARGS, $(INC_OPT))

.list-macro:
	@echo    "Compile-time defined macro - "
	@echo -n "                             "
	@$(call LIST_ARGS, $(VAR_DEF))

help list	:: .list-src .list-obj .list-inc .list-macro

#==============================================================================
# remove compilation products
#==============================================================================
clean		:: .clean-obj

.clean-obj	:
	rm -f $(OBJ) $(DEP)

#==============================================================================
#==============================================================================
.PHONY: build-obj clean help list \
		.build-src-dep .clean-obj \
		.list-src .list-obj .list-inc .list-macro  

#==============================================================================
# Function defintions
#==============================================================================

#-------------------------------------------------------------------
# FIND_SOURCE_FILES: wildcat ignore

