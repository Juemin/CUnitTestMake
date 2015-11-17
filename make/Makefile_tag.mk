## -*- Makefile -*-
##
## Created by jzhang

#### Input ####
# SRC

ifndef BASE_DIR
$(error >>>>> missing BASE_DIR <<<<<<)
endif

###
CSCOPE ?= cscope
###
CC_INC=/opt/AMDAPPSDK-3.0$
##-I./bin/LINUX__2_4__X86__32/api/common/inc/  -I./include/  -I./sil/include/  -I./sil/ppath/  -I./sil/nas/  -I./pds/include/  -I./imports/emcpvm/include/  -I./cli/include/  -I./imports/esnapi/include/  -I./imports/esnapi/inc_intern/  -I./stplib/btptodata/  -I./stplib/btp/  -I./stplib/stptobtp/  -I./stplib/asymdata/  -I./drivers/ksapi/include/  -I./imports/zlib/include/  -I./snmp/includ/  -I./imports/snmp/epilogue/  -I./imports/snmp/epilogue/envoy/h/  -I./imports/snmp/epilogue/common/h/  -I./imports/snmp/epilogue/envoy/port/Linux/  -I./third_party/elm/3.3.0/include/  -I./third_party/OpensslCache/LINUX__2_4__X86__32/include

#CC_OPT=-c -fpic -fsyntax-only -Wno-unused-variable -o /dev/nul

INC_DIR=/opt/AMDAPPSDK-3.0$/include
#include sil/include sil/ppath sil/nas pds/include imports/emcpvm/include cli/include imports/esnapi/include imports/esnapi/inc_intern stplib/btptodata stplib/btp stplib/stptobtp stplib/asymdata drivers/ksapi/include imports/zlib/include snmp/include imports/snmp/epilogue/envoy/h imports/snmp/epilogue/common/h imports/snmp/epilogue/envoy/port/Linux third_party/elm/3.3.0/include

#Include all subdirs from base dir
DEFAULT_EXCL_DIR=./bin
EXCL_DIRS=./.git ./.cvs ./.snapshot ./doc
excl_opts=-path $(DEFAULT_EXCL_DIR) $(foreach d,$(EXCL_DIRS),-or -path $(d))
incl_opts=-name *.c -or -name *.h -or -name *.cpp -or -name *.hpp
$(info dir:$(excl_opts) - $(incl_opts))
ALL_SRC=$(shell find . -type d \( $(excl_opts) \) -prune -o \( $(incl_opts) \) -print )

#
#src snmp/src sil/src pds/src cli/src imports/esnapi/src imports/snmp/epilogue/envoy/snmp MVSbuild/sapi/src

$(info $(ALL_SRC))

CC_INC= $(addprefix -I,$(INC_DIR))

#get_cs_flags = $(foreach target,$(subst .,_,$(subst -,_,$($(2)))),$($(target)_$(1)FLAGS))
#get_cs_all_flags = $(foreach type,$(2),$(call get_cs_flags,$(1),$(type)))
#get_cs_compile = $(if $(subst C,,$(1)),$(CXX),$(CC))
#get_cs_cmdline = $(call get_cs_compile,$(1)) $(call get_cs_all_flags,$(1),) $(CC_DEF) $(CC_INC) $(CC_OPT)

# not working yet
#check-syntax: 
#	s=$(suffix $(CHK_SOURCES));\
#	if   [ "$$s" = ".c"   ]; then $(call get_cs_cmdline,C) $(CHK_SOURCES);\
#	elif [ "$$s" = ".cpp" ]; then $(call get_cs_cmdline,CXX) $(CHK_SOURCES);\
#	else exit 1; fi
#default	: build-cscope

build-tag:
	$(ETAGS) $(TAG_SRC)

build-cscope:
	@echo  $(ALL_SRC) | tr ' ' '\n' > cscope.files
	cscope -b -q -i cscope.files
# cscope may have problems when using space-divided filenames.

.clean-tag::
	@rm -f TAGS cscope.files cscope.in.out  cscope.out  cscope.po.out

.PHONY: check-syntax build-tag build-cscope .clean-tag
