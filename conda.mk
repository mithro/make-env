# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier:	ISC

SHELL := /bin/bash

# Makefile for downloading and creating a conda environment.

# Usage
#  - Set TOP_DIR to the top directory where environment will be created.
#  - Set CONDA_ENV_NAME
#  - Set REQUIREMENTS_FILE to a pip `requirements.txt` file.
#  - Set ENVIRONMENT_FILE to a conda `environment.yml` file.
#  - Put $(IN_CONDA_ENV) before commands which should run inside the
#    environment.

# Configuration
ifeq (,$(CONDA_ENV_NAME))
$(error "Set CONDA_ENV_NAME value before including 'conda.mk'.")
endif

ifeq (,$(REQUIREMENTS_FILE))
$(error "Set REQUIREMENTS_FILE value before including 'conda.mk'.")
endif

ifeq (,$(ENVIRONMENT_FILE))
$(error "Set ENVIRONMENT_FILE value before including 'conda.mk'.")
endif

ifeq (,$(TOP_DIR))
$(error "Set TOP_DIR value before including 'conda.mk'.")
endif

# Detect the operating system
ifeq (,$(OS_FLAG))
  UNAME_S := $(shell uname -s)
  ifneq (, $(findstring Linux, $(UNAME_S)))
    OS_FLAG := Linux
  endif
  ifeq ($(UNAME_S), Darwin)
    OS_FLAG := MacOSX
  endif

  # On Cygwin / MINGW use Linux?
  ifneq (, $(findstring Cygwin, $(UNAME_S)))
    OS_FLAG := Linux
  endif
  ifneq (, $(findstring MINGW, $(UNAME_S)))
    OS_FLAG := Linux
  endif

  ifneq (, $(findstring MSYS_NT, $(UNAME_S)))
    OS_FLAG := Windows
  endif

  ifeq (,$(OS_FLAG))
    $(error "Unable to discover which OS to download conda from 'uname -s' output of '$(UNAME_S)'. Set OS_FLAG.")
  endif
endif

# Detect the CPU architecture
ifeq (,$(CPU_FLAG))
  UNAME_M := $(shell uname -m)
  CPU_FLAG := $(UNAME_M)
  ifeq (,$(CPU_FLAG))
    $(error "Unable to discover which CPU architecture to download conda from 'uname -m' output of '$(UNAME_M)'. Set CPU_FLAG.")
  endif
endif

ENV_DIR           := $(TOP_DIR)/env
CONDA_DIR         := $(ENV_DIR)/conda
DOWNLOADS_DIR     := $(ENV_DIR)/downloads
CONDA_PYTHON      := $(CONDA_DIR)/bin/python
CONDA_PKGS_DIR    := $(DOWNLOADS_DIR)/conda-pkgs
CONDA_PKGS_DEP    := $(CONDA_PKGS_DIR)/urls.txt
CONDA_ENV_PYTHON  := $(CONDA_DIR)/envs/$(CONDA_ENV_NAME)/bin/python
IN_CONDA_ENV_BASE := source $(CONDA_DIR)/bin/activate &&
IN_CONDA_ENV      := $(IN_CONDA_ENV_BASE) conda activate $(CONDA_ENV_NAME) &&

$(ENV_DIR): | $(DOWNLOADS_DIR)
	mkdir -p $(ENV_DIR)

$(DOWNLOADS_DIR):
	mkdir -p $(DOWNLOADS_DIR)

$(DOWNLOADS_DIR)/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh: | $(DOWNLOADS_DIR)
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh -O $(DOWNLOADS_DIR)/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh
	chmod a+x $(DOWNLOADS_DIR)/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh

$(CONDA_PKGS_DEP): $(CONDA_PYTHON)
	$(IN_CONDA_ENV_BASE) conda config --system --add pkgs_dirs $(CONDA_PKGS_DIR)
	mkdir -p $(CONDA_PKGS_DIR)
	touch $(CONDA_PKGS_DEP)

$(CONDA_PYTHON): $(DOWNLOADS_DIR)/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh
	$(DOWNLOADS_DIR)/Miniconda3-latest-$(OS_FLAG)-$(CPU_FLAG).sh -p $(CONDA_DIR) -b -f
	touch $(CONDA_PYTHON)

$(CONDA_DIR)/envs: $(CONDA_PYTHON)
	$(IN_CONDA_ENV_BASE) conda config --system --add envs_dirs $(CONDA_DIR)/envs

$(CONDA_ENV_PYTHON): $(ENVIRONMENT_FILE) $(REQUIREMENTS_FILE) | $(CONDA_PYTHON) $(CONDA_DIR)/envs $(CONDA_PKGS_DEP)
	$(IN_CONDA_ENV_BASE) conda env update --name $(CONDA_ENV_NAME) --file $(ENVIRONMENT_FILE)
	touch $(CONDA_ENV_PYTHON)

env: $(CONDA_ENV_PYTHON)
	$(IN_CONDA_ENV) conda info

.PHONY: env

enter: $(CONDA_ENV_PYTHON)
	$(IN_CONDA_ENV) bash

.PHONY: enter

clean:
	rm -rf $(CONDA_DIR)

.PHONY: clean

dist-clean:
	rm -rf $(ENV_DIR)

.PHONY: dist-clean

FILTER_TOP = sed -e's@$(TOP_DIR)/@$$TOP_DIR/@'
env-info:
	@echo "               Currently running on: '$(OS_FLAG) ($(CPU_FLAG))'"
	@echo
	@echo "   Conda Env Top level directory is: '$(TOP_DIR)'"
	@echo "         Git top level directory is: '$$(git rev-parse --show-toplevel)'"
	@echo "              The version number is: '$$(git describe)'"
	@echo "            Git repository is using: $$(du -h -s $$(git rev-parse --show-toplevel)/.git | sed -e's/\s.*//')" \
		| $(FILTER_TOP)
	@echo
	@echo "     Environment setup directory is: '$(ENV_DIR)'" \
		| $(FILTER_TOP)
	@echo "    Download and cache directory is: '$(DOWNLOADS_DIR)' (using $$(du -h -s $(DOWNLOADS_DIR) | sed -e's/\s.*//'))" \
		| $(FILTER_TOP)
	@echo "               Conda's directory is: '$(CONDA_DIR)' (using $$(du -h -s $(CONDA_DIR) | sed -e's/\s.*//'))" \
		| $(FILTER_TOP)
	@echo " Conda's packages download cache is: '$(CONDA_PKGS_DIR)' (using $$(du -h -s $(CONDA_PKGS_DIR) | sed -e's/\s.*//'))" \
		| $(FILTER_TOP)
	@echo "           Conda's Python binary is: '$(CONDA_ENV_PYTHON)'"\
		| $(FILTER_TOP)

.PHONY: env-info
