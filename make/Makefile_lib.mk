## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#==============================================================================
#
# Lib build supporting depending dir's library build
#
#==============================================================================

#==============================================================================
# Archive command version check
#==============================================================================
# AR needs to be binutils 2.24 or later to support " -T", thin archive
# to support building shared lib 
AR_THIN =
# Check ar version
AR_VER  = $(shell $(AR) -V | grep -m 1 " ar " | sed -n 's/.* \([0-9]\+\.[0-9]\+\).*/\1/gp')
ifneq "2.20" "$(word 1, $(sort 2.20 $(AR_VER)))"
# ar does not support thin archive
ifdef DEP_DIR
# Need to build dependency, but no thin archive, bail out.
$(info AR version: $(AR_VER))
$(error "Binutils ar does not support -T thin archive in $(AR_VER)")
endif #DEP_DIR
else
# Using thin archive to build lib
AR_THIN	= -T
endif

#==============================================================================
# Define common makefile functions
#==============================================================================

#---------------------------------------------------------------
# Archieve all depend lib objects and object files into one archive
# Extract depend archive objects and re-archive with object files in current dir
define ADD_DEP_LIB
$(AR) -Tcrs $(2); \
for i in $(1); do \
    if [[ $$i == *.o ]]; then \
        $(AR) -Trs $(2) $$i; \
    else \
        depobj=`$(AR) -t $$i`; \
        $(AR) -Tq $(2) $$depobj; \
    fi \
done
endef
# consider using libtool to replace ar -T, because -T is not available in older version of ar


#---------------------------------------------------------------
# DEF_EXPORT_LIB: [depending dir]
# Given depending dir, return depending dir lib name
define DEF_EXPORT_LIB
$(call GET_BIN_PATH,$(1))/$(BIN_DIR)/lib_$(notdir $(abspath $(1)))_direxp.a
endef

# GET_EXPORT_DIR: [libname in bin]
# Reverse of DEF_EXPORT_LIB, retrieve dir from given depending lib
define GET_EXPORT_DIR
$(call GET_SRC_PATH,$(patsubst %/$(BIN_DIR)/,%,$(dir $(1))))
endef

#---------------------------------------------------------------
define DEF_LOCAL_LIB
$(BIN_PATH)/lib_$(notdir $(CUR_PATH))_local.a
endef


#---------------------------------------------------------------
define INDENT
printf "[$(MAKELEVEL)]"; num=1; while [[ $$num -le $(MAKELEVEL) ]] ; \
do printf "$(1)"; ((num = num + 1)) ; done;  
endef

#==============================================================================
# Global variable definitions
#==============================================================================

#---------------------------------------------------------------
# Define lib object files in local dir by excluding all
# obj file containing main() function.
EXE_SRC	:= $(strip $(shell $(MK_DIR)/find_main.pl $(SRC)))
$(if $(DBG),$(info Set executable src ----- $(call SORT_LIST,$(EXE_SRC))))
#
LIB_OBJ	:= $(call DEF_OBJ_FILES,$(BIN_PATH),$(SRC),$(EXE_SRC))
$(if $(DBG),$(info Set lib source obj ----- $(call SORT_LIST,$(LIB_OBJ))))

#==============================================================================
# If lib objects or depending dir
#==============================================================================

#---------------------------------------------------------------
ifneq ($(LIB_OBJ) $(DEP_DIR),)
# We need to build a library for this dir
#---------------------------------------------------------------
#
$(if $(DBG),$(info Set depending dir ------ $(call SORT_LIST,$(DEP_DIR))))

#EXP_LIB_OBJ := $(LIB_OBJ)
#---------------------------------------------------------------
# Set local library
EXP_LIB		?= $(call DEF_EXPORT_LIB,.)
$(if $(DBG),$(info Set local explib ------- $(EXP_LIB)))
# Make a copy of $(DEP_DIR). It will be flushed in dir-dependency checking
# DEP_DIR_SET	:= $(DEP_DIR)
# If having depend dirs, get the lib names from the dirnames and add to depend lib
ifdef DEP_DIR
DEP_LIB    := $(foreach p,$(DEP_DIR),$(call DEF_EXPORT_LIB,$(p)))
else
DEP_LIB		=
endif
#
$(if $(DBG),$(info Set depending lib ------ $(call SORT_LIST,$(DEP_LIB))))

#---------------------------------------------------------------
# Temporary inter-media dir's lib and dependence files
LOCAL_LIB   := $(call DEF_LOCAL_LIB)

# File name containing the dependence rule for the exporting library
EXP_LIB_D   := $(EXP_LIB:.a=.dd)
DEP_LIB_D	:= $(DEP_LIB:.a=.dd)
# Dependence file loaded when building lib and exe
LIB_DEP_RULE:= $(EXP_LIB:.a=.rule)

# Libraries containing local objects in depending dirs 
DEP_LIB_LOCAL:=$(abspath $(DEP_LIB:direxp.a=local.a)) 
$(if $(DBG),$(info Set local lib ---------- $(LOCAL_LIB)))

# Time stamp for building dependence rules
export BUILD_DEP_TS?= $(abspath $(BIN_PATH)/.build_dep_start.ts)


#==============================================================================
# Build rules to build lib dependency rules, loading dynamically
#==============================================================================

#---------------------------------------------------------------
# Build lib dependence rule and touch the build time stamp
build-dep	: .touch-build-st .build-dep-rule

.touch-build-st	:
	$(if $(DBG),@printf "........................ ")
	$(if $(DBG),,@)touch $(BUILD_DEP_TS)

# Explicit rule to create the rule to build dir exporting lib
# The prerequisites of $(DEP_LIB_D) is built by applying the implicitly rule 
.build-dep-rule	: $(EXP_LIB_D) $(DEP_LIB_D)
	$(if $(DBG),@echo ------------------------ Adding lib-dep rule to $(EXP_LIB_D))
	$(if $(DBG),,@)$(MK_DIR)/add_lib_dependence.pl $^

# Implicit rule of creating dependence rule for export lib $(DEP_LIB_D) in $(DEP_DIR)
# Using starting timestamp to prevent re-build in a cyclic dependency
%_direxp.dd		: $(BUILD_DEP_TS)
	$(eval target_dir := $(call GET_EXPORT_DIR,$@))
	$(if $(DBG1),@$(call INDENT,"++++"))
	$(if $(DBG1),@echo Making lib dep for $(target_dir))
	$(if $(DBG1),@)pushd $(target_dir) > /dev/null && $(UMAKE) .build-dep-rule
	$(if $(DBG1),@$(call INDENT,"____"))
	$(if $(DBG1),@echo Done making rule in $(target_dir))

# Explicit rule to create the lib dependence rule in a file.
# Only Makefile changes, or $(DEP_DIR), should trigger its rebuild.
$(EXP_LIB_D)	: $(BUILD_DEP_TS)
	$(if $(DBG),@echo ------------------------ Creating lib-dep rule $(EXP_LIB_D))
ifdef DEP_LIB
	$(if $(DBG),,@)printf "$(EXP_LIB): $(DEP_LIB_LOCAL) " > $(EXP_LIB_D)
else
	$(if $(DBG),,@)printf "$(EXP_LIB): $(LOCAL_LIB_ABS) " > $(EXP_LIB_D)
endif

#---------------------------------------------------------------
$(LIB_DEP_RULE)	:
	$(if $(DBG1),@$(call INDENT,"++++"))
	$(UMAKE) build-dep
	$(if $(DBG1),@$(call INDENT,"____"))
	$(if $(DBG),,@)cp  $(EXP_LIB_D) $(LIB_DEP_RULE)	

#---------------------------------------------------------------
# Build dependence if not specified
#---------------------------------------------------------------
ifneq ($(filter-out build-dep .build-dep-rule .build-local-lib clean,\
		$(MAKECMDGOALS)),)
# Do not include dependence rule when building it
$(if $(DBG),$(info Load lib-dep rule ------ $(EXP_LIB_RULE)))
-include $(LIB_DEP_RULE)
endif

#==============================================================================
# Build exporting lib based on lib dependency rules
#==============================================================================

#---------------------------------------------------------------
# Build lib of dir based on lib dir's nested dependence or recursive dependence
build-lib	: $(EXP_LIB) $(if $(DEL_LIB_DEP),.clean-dep)

#---------------------------------------------------------------
# Creating export-lib based on local lib object files, additional rules
# are loaded by $(EXP_LIB_RULE)
$(EXP_LIB)	: $(LOCAL_LIB)
ifdef AR_THIN
	@echo ........................ Creating export-lib $@
	$(if $(DBG),,@)$(call ADD_DEP_LIB,$+,$@)
else
	@echo "No thin ar, use local lib as export lib"
	@cp $(LOCAL_LIB) $@
endif

#---------------------------------------------------------------
# Build lib only on current dir's object files
.build-local-lib: $(LOCAL_LIB)

#---------------------------------------------------------------
# Implicit rule to build lib, only apply for depending dirs
ifdef DEP_LIB
$(if $(DBG),$(info Set rule to build ------ Lib pattern *_local.a $(if $(DEP_CHECK),forced)))
%_local.a	: .FORCE
	$(eval target_dir := $(call GET_EXPORT_DIR,$@))
	@$(call INDENT,"++++")
	@echo Check depending lib in $(target_dir)
	$(if $(DBG1),,@)pushd $(target_dir) > /dev/null && $(UMAKE) .build-local-lib
	$(if $(DBG1),@$(call INDENT,"____"))
	$(if $(DBG1),@echo Done .build-local-lib in $(target_dir))
endif

#---------------------------------------------------------------
# Explicit rule to build local lib, applying for local dir
$(LOCAL_LIB)    : $(LIB_OBJ)
	$(if $(DBG),@echo ------------------------ Creating local lib $@)
	$(if $(DBG),@printf "........................ ")
	$(if $(DBG),,@)$(AR) $(AR_THIN) -crs $@ $^

#==============================================================================
# Clean rule
#==============================================================================
# remove compilation products
clean  	:: .clean-dep .clean-lib

.clean-dep :
	rm -f $(LIB_DEP_RULE)  $(EXP_LIB_D)

.clean-lib	:
	rm -f $(EXP_LIB) $(LOCAL_LIB)

#==============================================================================
# Fask key
#==============================================================================
dep	:
	$(UMAKE) build-dep

lib	:
	$(UMAKE) build-lib

#---------------------------------------------------------------
.PRECIOUS: $(EXP_LIB) $(EXP_LIB_D) $(BUILD_DEP_TS)

.DELETE_ON_ERROR: $(LIB_DEP_RULE) 
#---------------------------------------------------------------
endif # no LIB_OBJ or DEP_DIR
#---------------------------------------------------------------

#---------------------------------------------------------------
.PHONY	: build-dep build-lib dep lib .FORCE \
	  	 .touch-build-ts .build-dep-rule  .build-local-lib \
		  clean .clean-dep .clean-lib

