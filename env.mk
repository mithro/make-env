# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier:	ISC

.SUFFIXES:

MAKE_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

SHELL := bash

# Makefile for downloading and creating environments (with tools like conda).

# Usage
#  - Set TOP_DIR to the top directory where environment will be created.
#  - Set REQUIREMENTS_FILE to a pip `requirements.txt` file.
#  - Set ENVIRONMENT_FILE to a conda `environment.yml` file.
#  - Put $(IN_ENV) before commands which should run inside the
#    environment.

# Configuration
ifeq (,$(TOP_DIR))
$(error "Set TOP_DIR value before including 'env.mk'.")
endif

ifeq (,$(REQUIREMENTS_FILE))
$(error "Set REQUIREMENTS_FILE value before including 'conda.mk'.")
else
REQUIREMENTS_FILE := $(abspath $(REQUIREMENTS_FILE))
endif
ifeq (,$(wildcard $(REQUIREMENTS_FILE)))
$(error "REQUIREMENTS_FILE ($(REQUIREMENTS_FILE)) does not exist!?")
endif

ifeq (,$(ENVIRONMENT_FILE))
$(error "Set ENVIRONMENT_FILE value before including 'conda.mk'.")
ENVIRONMENT_FILE := $(abspath $(ENVIRONMENT_FILE))
endif
ifeq (,$(wildcard $(ENVIRONMENT_FILE)))
$(error "ENVIRONMENT_FILE ($(ENVIRONMENT_FILE)) does not exist!?")
endif

# Default to conda if no other option is provided.
ifeq (,$(ENV))
ENV := conda
endif

ifeq (,$(wildcard $(MAKE_DIR)/$(ENV).mk))
$(error Unknown environment provider (ENV='$(ENV)')?)
endif

export ENV
include $(MAKE_DIR)/$(ENV).mk
ifeq (,$(UENV))
$(error Missing UENV definition)
endif

ENV_PYTHON := $($(UENV)_ENV_PYTHON)
IN_ENV     := $(IN_$(UENV)_ENV)

clean::
	true

.PHONY: clean

dist-clean::
	true

.PHONY: dist-clean

enter: | $(ENV_PYTHON)
	$(IN_ENV) bash

.PHONY: enter

info: | $(ENV_PYTHON)
	@$(IN_ENV) $(MAKE) --no-print-directory env-info

.PHONY: info
