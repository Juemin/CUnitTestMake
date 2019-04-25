## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2019

#==============================================================================
#
# Setup include path list using DEP_DIR
#
#==============================================================================

local_inc_mk	:= $(BIN_PATH)/local_inc_path.mk
exp_inc_mk		:= $(BIN_PATH)/exp_inc_path.mk
ifneq ($(DEP_DIR),)
include $(exp_inc_mk)
endif

cur_inc_abspath := $(abspath $(DEP_DIR))
imp_inc_path 	= $(filter-out $(cur_inc_abspath), $(EXP_INC_PATH))
##$(shell export EXP_INC_PATH="$(EXP_INC_PATH)")

#$(info ===== Local depend inc  : $(cur_inc_abspath))
#$(info ===== Import depend inc : $(imp_inc_path))

#-------------------------------------------------------------------------------
.build-inc-mk : $(exp_inc_mk)

$(exp_inc_mk)	: $(local_inc_mk)  | $(BIN_PATH)
	$(if $(DBG),,@)touch $@
	$(foreach d, $(DEP_DIR), $(if $(DBG1),,@)pushd $(d) > /dev/null && $(UMAKE) .build-inc-mk && popd > /dev/null;)
	$(foreach d, $(DEP_DIR), $(if $(DBG),,@)$(MK_DIR)/combine_inc.py -i $(call GET_BIN_PATH,$(CUR_PATH)/$(d)/$(BIN_DIR)/exp_inc_path.mk -o $@;))
	$(if $(DBG),,@)$(MK_DIR)/combine_inc.py -i $< -o $@

$(local_inc_mk) :
	$(if $(DBG),,@)printf "EXP_INC_PATH += $(cur_inc_abspath)\n" > $@
#-------------------------------------------------------------------------------
clean	::
	@rm -f $(local_inc_mk) $(exp_inc_mk)

.PHONY: clean .build-inc-mk


