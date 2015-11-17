## -*- Makefile -*-
##
## User: jzhang
## Time: Apr 23, 2014 10:17:57 AM

#==============================================================================
#
# Link object files and libraries
#
#==============================================================================

#==============================================================================
# Defining variables
#==============================================================================

# List of target exe in tests
EXE_PATH	:= $(addprefix $(BIN_PATH)/,$(call DEF_EXE_NAME,$(SRC)))
$(if $(DBG),$(info Set build executable --- $(EXE_PATH)))

# List of executable object files, no lib objects
EXE_OBJ		?= $(addsuffix .o,$(EXE_PATH))
$(if $(DBG),$(info Set executable obj ----- $(EXE_OBJ)))

#==============================================================================
# Link rule
#==============================================================================
# External libraries must be checked. Abort if any is missing
# This is to avoid no matching rule for building exe

# Do not load exe build rule if we don't have any executable to build
ifneq ($(EXE_PATH),)

build-exe		:  build-lib $(EXE_PATH)

$(BIN_PATH)/% 	: $(BIN_PATH)/%.o $(EXP_LIB)
	$(if $(DBG),@echo ------------------------ Link executable $@)
	$(if $(DBG),,@)$(GXX) -g $(LDFLAGS) $+ $(EXT_LIB) -o $@ $(LNKFLAGS)
else
build-exe		: build-lib
endif

#==============================================================================
# remove compilation products
#==============================================================================
.clean-exe	:
		$(if $(DBG),,@)rm -f $(EXE_PATH)

clean		:: .clean-exe

#==============================================================================
# help and check rule
#==============================================================================

.list-exe	:
	@$(call PRINT_HELP_TOPIC,exe,Make targets for executables in current dir)


#-----------------------------------------
.list-ld	:
	@echo    "Link-time lib search path -- "
	@echo -n "                             "
	@$(call LIST_ARGS, $(LDFLAGS))

.list-lib	:
	@echo    "Link-time static lib -------- $(EXT_LIB)"
	@echo    "Link-time dynamic lib ------- "
	@echo -n "                             "
	@$(call LIST_ARGS, $(LNKFLAGS))

help		:: .list-exe .list-ld .list-lib

#-----------------------------------------
.PHONY	: build-exe clean help \
		 .clean-exe  \
		 .list-exe .list-ld .list-lib 

