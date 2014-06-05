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
TARGET	    := $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Set target executable --- $(TARGET))
endif
ifndef EXE_OBJ
EXE_OBJ	    := $(addsuffix .o,$(TARGET))
$(info Set executable obj ----- $(EXE_OBJ))
endif
LIB_OBJ	    := $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),$(EXE_OBJ))
$(info Set lib source obj ----- $(LIB_OBJ))
endif
EXP_LIB_OBJ := $(addprefix $(abspath .),$(LIB_OBJ))

# Define lib for caller in different directories
# Get current dir's name to form lib name
ifndef EXP_LIB
EXP_LIB	    := $(call DEF_EXPORT_LIB,.,$(BD_DIR))
# This is lib name based on dir name
$(info Set lib .a ------------- $(EXP_LIB))
endif

# If have depend dirs, get the lib names from the dirnames and add to depend lib
ifdef DEP_DIR
DEP_LIB    := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p),$(BD_DIR)))
DEP_DIR	    =
$(info Set depend libs -------- $(DEP_LIB))
endif


#================================================================
# Temporary inter-media dir's lib and dependence files
LOCAL_LIB   := $(call DEF_LOCAL_LIB,.,$(BD_DIR))
LOCAL_LIB_ABS:= $(abspath $(LOCAL_LIB)) 
# Dir lib dependence file, including all nested libs in other dirs
EXP_LIB_D   := $(EXP_LIB:.a=.d)
# Temporary dependence, remove after it is done
EXP_LIB_DI  := $(EXP_LIB:.a=.di)
# Lib's dependence file
DEP_LIB_DI  := $(DEP_LIB:.a=.di)
DEP_LIB_LOCAL:=$(abspath $(DEP_LIB:direxp.a=local.a)) 

#--------------------------------------
# Build lib dependence file. 
# This file specifies the prerequisite and rule to build the library for 
# exporting. It is included in $(MAKEFILE_LIST) before building the library.
.build-dep	: $(EXP_LIB_D)

# Lib dependence file has two prerequisits.
# 1) Initial library inter-media dependence file, which is built using the explicit
# rule.  It contains the prerequisite and rule of building the library, however,
# the depending library's dependences are not resolved.
# 2) $(DEP_LIB_DI) is the list of dependence inter-media file names from the 
# depending dirs, and they are built by using the implicit rule recursively.
# 
# After the two prerequisites are built, the lib dependence file is built by
# expanding the dependence libs' inter-media files.
# Then, the inter-media dependence file is copied to the dependence file.
$(EXP_LIB_D)	: $(EXP_LIB_DI) $(DEP_LIB_DI)
	$(BASE_DIR)/make/add_lib_dependence.pl $^
	cp $(EXP_LIB_DI) $(EXP_LIB_D)

# Explicit rule to initialize the inter-media dependence file.  
# Only Makefile changes, or more# specifically, the $(DEP_DIR) change, triggers 
# its re-building.
$(EXP_LIB_DI)	: $(MAKEFILE_LIST)
	@printf "$(EXP_LIB): $(LOCAL_LIB_ABS) "	> $(EXP_LIB_DI);
	@if [ ! $(DEP_LIB) ]; then \
	    printf "\\ \n\t$(DEP_LIB_LOCAL) \n"	>> $(EXP_LIB_DI); \
	fi

# Implicit rule of build depending lib's inter-media dependence file.
# We don't have a good method to monitor depending lib changes.
%_direxp.di	:
	@echo Build lib dependence $@
	$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-lib-di

# Target .build-lib-di is to build a temporary dependence file to capture lib 
#dependences among directories.  It is built based on two parts:
# 1) the local lib dependence in the same dir
# 2) lib dependences from other depending dirs
# It is a recursive build process
.build-lib-di	: $(EXP_LIB_DI) $(DEP_LIB_DI)
	$(BASE_DIR)/make/add_lib_dependence.pl $^


#==============================================================================
# Load lib's dependence
-include $(EXP_LIB_D)

# Build lib of dir based on lib dir's nested dependence or recursive dependence
.build-lib  : $(EXP_LIB)

# Build lib only on current dir's object files
.build-local-lib: $(LIB_OBJ)
	@ar -Tcrs $(LOCAL_LIB) $(LIB_OBJ)

# Build lib based on lib dependence. The prerequisite includes dir's obj files
# and dependence lib files, containing only their dir's object files.
$(EXP_LIB)  : $(LIB_OBJ)
	@echo "make export lib of dir:$@"
	$(call ADD_DEP_LIB,$^,$@)

# Implicit rule to build depending local libs
%_local.a  :
	@echo Build depending lib $@
	$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-local-lib


# Archieve all depend lib objects and object files into one archive
# Extract depend archive objects and re-archive with object files in current dir
define ADD_DEP_LIB
@ar -Tcrs $(2); \
for i in $(1); do \
    if [[ $$i == *.o ]]; then \
	ar -Trs $(2) $$i; \
    else \
	depobj=`ar -t $$i`; \
	ar -Tq $(2) $$depobj; \
    fi \
done
endef

#----------------------
.echo-libobj:
	@echo $(EXP_LIB_OBJ)

# remove compilation products
.clean	    ::
	@rm -f $(EXP_LIB) $(LOCAL_LIB)

.clean-lib-dep	:
	@rm -f $(EXP_LIB_D)

PHONY	: .build-lib .echo-explib .echo-libobj .clean .build-lib-local \
	  .build-dep .build-lib-di .build-lib-dir
