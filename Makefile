#!/usr/bin/env make -f

SELF := $(abspath $(lastword $(MAKEFILE_LIST)))
REFS += $(SELF)
TOPDIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

_reverse = $(if $(1),$(call _reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

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
	jq \
	libncurses5-dev \
	libssl-dev \
	python3 \
	python3-setuptools \
	python3-venv \
	rsync \
	subversion \
	swig \
	time \
	unzip \
	xsltproc \
	zip \
	zlib1g-dev

.PHONY: help
help: ## Show help message (list targets)
	@{ \
	printf "\nTargets:\n" ; \
	count=0 ; \
	for ref in $(call _reverse,$(REFS)); do \
		awk 'BEGIN {FS = ":.*##"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $${ref} ; \
		count=$$((count + 1)) ; \
	done ; \
	}

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

include $(TOPDIR)/Makefile.crossbuild

.PHONY: install-deps
install-deps: ## Install dependencies
	sudo apt-get update
	sudo apt-get install --no-install-recommends --no-install-suggests -y $(DEPS)

.PHONY: up
up: ## Set up Vagrant environment
	vagrant up
