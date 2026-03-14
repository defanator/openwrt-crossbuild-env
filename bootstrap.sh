#!/usr/bin/env bash

set -exo pipefail

cd "${HOME}"

if ! grep -q -- "provisioned by vagrant" .profile >/dev/null; then
    cat <<EOF >>.profile
# provisioned by vagrant
export LC_ALL=C
unset LC_CTYPE
eval "\$(direnv hook bash)"
EOF
fi

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

if [ ! -d mcespi ]; then
    git clone https://github.com/defanator/mcespi.git
    ( cd mcespi && git checkout wip-ar71xx )
fi

sudo mv motd /etc/
