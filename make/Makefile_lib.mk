## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

# Lib build supporting depending dir's library build

# AR needs to be binutils 2.24 or later to support " -T", thin archive
# to support building shared lib 
AR 	= $(shell which ar)

# Check ar version
AR_VER  = $(shell $(AR) -V | grep "Binutils" | sed 's/[^0-9.]//g')
ifneq "2.24" "$(word 1, $(sort 2.24 $(AR_VER)))"
# ar does not support thin archive
ifdef DEP_DIR
# Need to build dependency, but no thin archive, bail out.
$(info AR version: $(AR_VER))
$(error "Binutils ar does not support -T thin archive in $(AR_VER)")
endif #DEP_DIR
else
# Using thin archive to build lib
AR	+= -T
endif

#### Input ####
# SRC
# Define test source file
# Source files are defined at the entry Makefile

# Define object files which are used to build lib only
# Those with main() are build into exe, else are built into lib
ifndef LIB_OBJ
# Exclude those not belong to lib
ifndef TARGET
TARGET	    := $(call DEF_TARGET_EXE,$(BD_DIR),$(SRC))
$(info Set target executable --- $(TARGET))
endif #end ifndef TARGET
ifndef EXE_OBJ
EXE_OBJ	    := $(addsuffix .o,$(TARGET))
$(info Set executable obj ----- $(EXE_OBJ))
endif #end ifndef EXE_OBJ
LIB_OBJ	    := $(call DEF_OBJ_FILES,$(BD_DIR),$(SRC),$(EXE_OBJ))
$(info Set lib source obj ----- $(LIB_OBJ))
endif #end ifndef LIB_OBJ

EXP_LIB_OBJ := $(addprefix $(abspath .),$(LIB_OBJ))

# Define lib for caller in different directories
# Get current dir's name to form lib name
ifndef EXP_LIB
EXP_LIB	    := $(call DEF_EXPORT_LIB,.,$(BD_DIR))
# This is lib name based on dir name
$(info Set lib .a ------------- $(EXP_LIB))
endif

# If have depending dirs, get the lib names from the dirnames and add to depend lib
ifdef DEP_DIR
DEP_LIB    := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p),$(BD_DIR)))
# Clear the dependence dirs
DEP_DIR	    =
$(info Set depend libs -------- $(DEP_LIB))
else
DEP_LIB	   =
endif


#================================================================
# Temporary inter-media dir's lib and dependence files
LOCAL_LIB   := $(call DEF_LOCAL_LIB,.,$(BD_DIR))
LOCAL_LIB_ABS:= $(abspath $(LOCAL_LIB)) 
# Dir lib dependence file, including all nested libs in other dirs
EXP_LIB_D   := $(EXP_LIB:.a=.d)
# Temporary dependence, copy to .d after it is done
EXP_LIB_DI  := $(EXP_LIB:.a=.d.i)
# Lib's dependence file, temporary dependence file
DEP_LIB_DI  := $(DEP_LIB:.a=.d.i)
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
# Only Makefile changes, more specifically, the $(DEP_DIR) change, triggers 
# its re-building.
$(EXP_LIB_DI)	: $(MAKEFILE_LIST)
		@printf "$(EXP_LIB): $(LOCAL_LIB_ABS) "	> $(EXP_LIB_DI);
		@if [ ! $(DEP_LIB) ]; then \
	    	   printf "\\ \n\t$(DEP_LIB_LOCAL) \n"	>> $(EXP_LIB_DI); \
		fi

# Implicit rule of build depending lib's inter-media dependence file.
# We don't have a good method to monitor depending lib changes.
%_direxp.d.i	:
		@echo Build lib dependence $@
		$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-lib-d-i

# Target .build-lib-di is to build a temporary dependence file to capture lib 
#dependences among directories.  It is built based on two parts:
# 1) the local lib dependence in the same dir
# 2) lib dependences from other depending dirs
# It is a recursive build process
.build-lib-d-i	: $(EXP_LIB_DI) $(DEP_LIB_DI)
		$(BASE_DIR)/make/add_lib_dependence.pl $^


#==============================================================================
# Load lib's dependence
-include $(EXP_LIB_D)

# Build lib of dir based on lib dir's nested dependence or recursive dependence
.build-lib  : $(EXP_LIB)

# Build lib based on lib dependence. The prerequisite includes dir's obj files
# and dependence lib files, containing only their dir's object files.
# -include $(EXP_LIB_D) will add more from the dir's dependence
$(EXP_LIB)	: $(LOCAL_LIB) 
		@echo "make export lib $@ from $^"
		$(call ADD_DEP_LIB,$^,$@)

# Implicit rule to build depending local libs
%_local.a	:
		@echo Build depending lib $@
		$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-local-lib

# Build lib only on current dir's object files
.build-local-lib: $(LOCAL_LIB)


$(LOCAL_LIB)    : $(LIB_OBJ)
		@rm -f $@
		$(AR) -crs $@ $^

# Archieve all depend lib objects and object files into one archive
# Extract depend archive objects and re-archive with object files in current dir
define ADD_DEP_LIB
@$(AR) -Tcrs $(2); \
for i in $(1); do \
    if [[ $$i == *.o ]]; then \
        $(AR) -rs $(2) $$i; \
    else \
        depobj=`$(AR) -t $$i`; \
        $(AR) -q $(2) $$depobj; \
    fi \
done
endef


# consider using libtool to replace ar -T, because -T is not available in older version of ar

#----------------------
.echo-libobj	:
		@echo $(EXP_LIB_OBJ)

# remove compilation products
.clean	    	::
		rm -f $(EXP_LIB) $(LOCAL_LIB)

.clean-lib-dep	:
		rm -f $(EXP_LIB_D)

PHONY	: .build-lib .echo-explib .echo-libobj .clean .build-lib-local \
	  .build-dep .build-lib-di .build-lib-dir
