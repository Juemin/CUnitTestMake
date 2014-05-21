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
add_lib	    := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p),$(BD_DIR)))
DEP_LIB	    += $(add_lib)
DEP_DIR	    =
$(info Set depend libs -------- $(DEP_LIB))
endif


#================================================================
# Temporary inter-media dir's lib and dependence files
LOCAL_LIB   := $(call DEF_LOCAL_LIB,.,$(BD_DIR))
# Dir lib dependence file, including all nested libs in other dirs
EXP_LIB_D   := $(EXP_LIB:.a=.d)
# Temporary dependence, remove after it is done
EXP_LIB_DI  := $(EXP_LIB:.a=.di)
# Lib's dependence file
DEP_LIB_DI  := $(DEP_LIB:.a=.di)
DEP_LIB_LOCAL:= $(abspath $(DEP_LIB:direxp.a=local.a))

#--------------------------------------
# Build lib dependence. Dependence is built explicitly, no prerequisite check
.build-lib-d: .build-lib-di
	mv $(EXP_LIB_DI) $(EXP_LIB_D)

.build-lib-di: $(EXP_LIB_DI) $(DEP_LIB_DI)
	$(BASE_DIR)/make/add_lib_dependence.pl $^

$(EXP_LIB_DI):
	@printf "$(EXP_LIB): "			>  $(EXP_LIB_DI);
	@if [ ! $(DEP_LEB_ABS) ]; then \
	    printf "\\ \n\t$(DEP_LIB_LOCAL) \n"	>> $(EXP_LIB_DI); \
	fi

# Build lib dependence using implicit rule
%_direxp.di :  
	@echo Build lib dependence $@
	$(MAKE) -C $(call GET_LIB_DIR,$@,$(BD_DIR)) .build-lib-di

#==============================================================================

# Build lib of dir based on lib dir's nested dependence or recursive dependence
.build-lib  : $(EXP_LIB)

# Build lib only on current dir's object files
.build-local-lib: $(LIB_OBJ)
	@ar -Tcrs $(LOCAL_LIB) $(LIB_OBJ)

# Load lib's dependence
-include $(EXP_LIB_D)
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


PHONY: .build-lib .echo-explib .echo-libobj .clean .build-lib-local \
	.build-lib-d .build-lib-dir
