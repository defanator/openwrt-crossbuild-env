#!/usr/bin/env bash

set -exo pipefail

cd "${HOME}"
echo "export LC_ALL=C" >> "${HOME}/.profile"
echo "unset LC_CTYPE" >> "${HOME}/.profile"
echo "eval \"\$(direnv hook bash)\"" >> "${HOME}/.profile"

sudo apt-get update
sudo apt-get install --no-install-recommends --no-install-suggests -y \
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

git clone https://github.com/defanator/mcespi.git
( cd mcespi && git checkout wip-ar71xx )

sudo mv motd /etc/
