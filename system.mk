# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier:	ISC

ENV := system
UENV := SYSTEM

include $(MAKE_DIR)/os.mk

SYSTEM_ENV_PYTHON  :=
IN_SYSTEM_ENV      :=

FILTER_TOP = sed -e's@$(TOP_DIR)/@$$TOP_DIR/@'
env-info:
	@echo
	@echo "                         Using system environment."
	@echo "               Currently running on: '$(OS_TYPE) ($(CPU_TYPE))'"
	@echo
	@echo "         Git top level directory is: '$$(git rev-parse --show-toplevel)'"
	@echo "              The version number is: '$$(git describe)'"
	@echo "                   Python binary is: '$$(which python)'"\
		| $(FILTER_TOP)

.PHONY: env-info
