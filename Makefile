#!/usr/bin/env make -f

SHELL := /bin/bash -euo pipefail

SELF := $(abspath $(lastword $(MAKEFILE_LIST)))
TOPDIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

OPENWRT_REMOTE   ?= https://github.com/openwrt/openwrt.git
OPENWRT_SRCDIR   ?= $(TOPDIR)/openwrt
STAGING_DIR      := $(OPENWRT_SRCDIR)/staging_dir

OPENWRT_RELEASE   ?= 23.05.3
OPENWRT_ARCH      ?= mips_24kc
OPENWRT_TARGET    ?= ath79
OPENWRT_SUBTARGET ?= generic
OPENWRT_VERMAGIC  ?= auto

OPENWRT_SNAPSHOT_REF ?= main

# for generate-target-matrix
OPENWRT_RELEASES ?= $(OPENWRT_RELEASE)

ifneq ($(OPENWRT_RELEASE),snapshot)
OPENWRT_ROOT_URL  ?= https://downloads.openwrt.org/releases
OPENWRT_BASE_URL  ?= $(OPENWRT_ROOT_URL)/$(OPENWRT_RELEASE)/targets/$(OPENWRT_TARGET)/$(OPENWRT_SUBTARGET)
OPENWRT_MANIFEST  ?= $(OPENWRT_BASE_URL)/openwrt-$(OPENWRT_RELEASE)-$(OPENWRT_TARGET)-$(OPENWRT_SUBTARGET).manifest
OPENWRT_PKG_EXT   := .ipk
else
OPENWRT_ROOT_URL  ?= https://downloads.openwrt.org/snapshots
OPENWRT_BASE_URL  ?= $(OPENWRT_ROOT_URL)/targets/$(OPENWRT_TARGET)/$(OPENWRT_SUBTARGET)
OPENWRT_MANIFEST  ?= $(OPENWRT_BASE_URL)/openwrt-$(OPENWRT_TARGET)-$(OPENWRT_SUBTARGET).manifest
OPENWRT_PKG_EXT   := .apk
endif

NPROC ?= $(shell getconf _NPROCESSORS_ONLN)

ifndef OPENWRT_VERMAGIC
_NEED_VERMAGIC=1
endif

ifeq ($(OPENWRT_VERMAGIC), auto)
_NEED_VERMAGIC=1
endif

OPENWRT_RELEASE_NUM := $(shell echo $(OPENWRT_RELEASE) | awk -F. '{printf "%02d%02d%02d", $$1, $$2, $$3}')

ifeq ($(_NEED_VERMAGIC), 1)
ifeq ($(OPENWRT_RELEASE), snapshot)
OPENWRT_VERMAGIC := $(shell curl -fsS $(OPENWRT_MANIFEST) | grep -- "^kernel" | sed -e "s,.*\~,," | cut -d '-' -f 1)
else
ifeq ($(shell [ $(OPENWRT_RELEASE_NUM) -ge 240000 ] && echo true || echo false), true)
OPENWRT_VERMAGIC := $(shell curl -fsS $(OPENWRT_MANIFEST) | grep -- "^kernel" | sed -e "s,.*\~,," | cut -d '-' -f 1)
else
OPENWRT_VERMAGIC := $(shell curl -fsS $(OPENWRT_MANIFEST) | grep -- "^kernel" | sed -e "s,.*\-,,")
endif
endif
endif

OPENWRT_SDK     := $(shell curl -fsS $(OPENWRT_BASE_URL)/ | sed -n 's/.*href="\(openwrt-sdk-[^"]*\)".*/\1/p')
OPENWRT_SDK_URL := $(OPENWRT_BASE_URL)/$(OPENWRT_SDK)

OPENWRT_TOOLCHAIN     := $(shell curl -fsS $(OPENWRT_BASE_URL)/ | sed -n 's/.*href="\(openwrt-toolchain-[^"]*\)".*/\1/p')
OPENWRT_TOOLCHAIN_URL := $(OPENWRT_BASE_URL)/$(OPENWRT_TOOLCHAIN)

DEPS := \
	build-essential \
	ca-certificates \
	ccache \
	direnv \
	file \
	flex \
	gawk \
	gcc \
	gdb \
	gettext \
	git \
	libncurses5-dev \
	libssl-dev \
	python3 \
	python3-setuptools \
	rsync \
	subversion \
	swig \
	time \
	unzip \
	xsltproc \
	zip \
	zlib1g-dev

help: ## Show help message (list targets)
	@awk 'BEGIN {FS = ":.*##"; printf "\nTargets:\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(SELF)

SHOW_ENV_VARS = \
	SHELL \
	SELF \
	TOPDIR \
	OPENWRT_REMOTE \
	OPENWRT_SRCDIR \
	OPENWRT_RELEASE \
	OPENWRT_RELEASE_NUM \
	OPENWRT_ARCH \
	OPENWRT_TARGET \
	OPENWRT_SUBTARGET \
	OPENWRT_VERMAGIC \
	OPENWRT_SNAPSHOT_REF \
	OPENWRT_BASE_URL \
	OPENWRT_MANIFEST \
	OPENWRT_SDK \
	OPENWRT_SDK_URL \
	OPENWRT_TOOLCHAIN \
	OPENWRT_TOOLCHAIN_URL \
	OPENWRT_PKG_EXT \
	NPROC

show-var-%:
	@{ \
	escaped_v="$(subst ",\",$($*))" ; \
	if [ -n "$$escaped_v" ]; then v="$$escaped_v"; else v="(undefined)"; fi; \
	printf "%-21s %s\n" "$*" "$$v"; \
	}

show-env: $(addprefix show-var-, $(SHOW_ENV_VARS)) ## Show environment details

export-var-%:
	@{ \
	escaped_v="$(subst ",\",$($*))" ; \
	if [ -n "$$escaped_v" ]; then v="$$escaped_v"; else v="(undefined)"; fi; \
	printf "%s=%s\n" "$*" "$$v"; \
	}

export-env: $(addprefix export-var-, $(SHOW_ENV_VARS)) ## Export environment

.venv:
	python3 -m venv $(TOPDIR)/.venv
	$(TOPDIR)/.venv/bin/python3 -m pip install -r $(TOPDIR)/requirements.txt

venv: .venv ## Create virtualenv

.PHONY: generate-target-matrix
generate-target-matrix: .venv ## Generate target matrix of build environments for GitHub CI
	@printf "BUILD_MATRIX=%s" "$$($(TOPDIR)/.venv/bin/python3 $(TOPDIR)/ci/generate_target_matrix.py --config $(TOPDIR)/ci/target-matrix-config.yaml $(OPENWRT_RELEASES))"

.PHONY: install-deps
install-deps: ## Install dependencies
	sudo apt-get update
	sudo apt-get install --no-install-recommends --no-install-suggests -y $(DEPS)

.PHONY: fix-host-symlinks
fix-host-symlinks: ## Fix symlinks from staging_dir/host/bin
	STAGING_DIR=$(STAGING_DIR) $(TOPDIR)/ci/fix-host-symlinks.sh

$(OPENWRT_SRCDIR):
	@{ \
	set -eux ; \
	git clone $(OPENWRT_REMOTE) $@ ; \
	if [ "$(OPENWRT_RELEASE)" != "snapshot" ]; then \
		cd $@ ; \
		git checkout v$(OPENWRT_RELEASE) ; \
	else \
		cd $@ ; \
		git checkout $(OPENWRT_SNAPSHOT_REF) ; \
	fi ; \
	}

$(OPENWRT_SRCDIR)/feeds.conf: | $(OPENWRT_SRCDIR)
	@{ \
	set -exo pipefail ; \
	curl -fsSL $(OPENWRT_BASE_URL)/feeds.buildinfo | tee $@ ; \
	cd $(OPENWRT_SRCDIR) ; \
	./scripts/feeds update -a ; \
	./scripts/feeds install -a ; \
	}

$(OPENWRT_SRCDIR)/.config: | $(OPENWRT_SRCDIR)
	@{ \
	set -exo pipefail ; \
	curl -fsSL $(OPENWRT_BASE_URL)/config.buildinfo | tee $@ ; \
	}

$(OPENWRT_SDK):
	curl -fLO $(OPENWRT_SDK_URL)

$(OPENWRT_TOOLCHAIN):
	curl -fLO $(OPENWRT_TOOLCHAIN_URL)

$(STAGING_DIR): | $(OPENWRT_SRCDIR) $(OPENWRT_SRCDIR)/feeds.conf $(OPENWRT_SRCDIR)/.config $(OPENWRT_SDK)
	@{ \
	set -ex ; \
	tar -xf $(OPENWRT_SDK) --strip-components=1 -C $(OPENWRT_SRCDIR) --wildcards '*/staging_dir' ; \
	toolchain_dir=$$(find $(STAGING_DIR)/ -type d -name "toolchain-*") ; \
	cd $(OPENWRT_SRCDIR) ; \
	mkdir -p $${toolchain_dir}/stamp ; \
	git log --format=%h -1 toolchain > $${toolchain_dir}/stamp/.ver_check ; \
	}

prepare: | $(STAGING_DIR) ## Fetch OpenWrt sources and toolchain

.PHONY: build-toolchain
build-toolchain: $(OPENWRT_SRCDIR)/feeds.conf $(OPENWRT_SRCDIR)/.config ## Build OpenWrt toolchain
	@{ \
	set -ex ; \
	cd $(OPENWRT_SRCDIR) ; \
	time -p make defconfig ; \
	time -p make tools/install -j $(NPROC) ; \
	time -p make toolchain/install -j $(NPROC) ; \
	}

.PHONY: build-kernel
build-kernel: $(OPENWRT_SRCDIR)/feeds.conf $(OPENWRT_SRCDIR)/.config ## Build OpenWrt kernel
	@{ \
	set -ex ; \
	cd $(OPENWRT_SRCDIR) ; \
	time -p make defconfig ; \
	time -p make V=s target/linux/compile -j $(NPROC) ; \
	VERMAGIC=$$(cat ./build_dir/target-$(OPENWRT_ARCH)*/linux-$(OPENWRT_TARGET)_$(OPENWRT_SUBTARGET)/linux-*/.vermagic) ; \
	echo "Vermagic: $${VERMAGIC}" ; \
	if [ "$${VERMAGIC}" != "$(OPENWRT_VERMAGIC)" ]; then \
		echo "Vermagic mismatch: $${VERMAGIC}, expected $(OPENWRT_VERMAGIC)" ; \
		exit 1 ; \
	fi ; \
	}
