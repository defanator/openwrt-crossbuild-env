#!/usr/bin/env bash

set -exo pipefail

GITROOT="${HOME}/git"

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
	cmake \
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

mkdir -p "${GITROOT}"

if [ ! -d "${GITROOT}/mcespi" ]; then
    pushd "${GITROOT}"
    git clone https://github.com/defanator/mcespi.git
    ( cd mcespi && git checkout wip-ar71xx )
    popd
fi

if [ ! -d "${GITROOT}/usign" ]; then
    pushd "${GITROOT}"
    git clone https://github.com/openwrt/usign.git
    cd usign
    mkdir build
    cd build
    cmake ..
    make -j
    sudo install -m755 usign /usr/bin/
    popd
fi

if [ ! -f "${HOME}/.envrc" ]; then
    cat <<EOF >"${HOME}/.envrc"
# use this to e.g. pull openwrt sources from single local clone instead of real upstream
#export OPENWRT_REMOTE=/vagrant/openwrt
EOF
    direnv allow
fi

if [ ! -f "${GITROOT}/openwrt-crossbuild-env/.envrc" ]; then
    cat <<EOF >"${GITROOT}/openwrt-crossbuild-env/.envrc"
source_env /home/vagrant
export _ROOT_SRCDIR=/home/vagrant/git
EOF
    pushd "${GITROOT}/openwrt-crossbuild-env"
    direnv allow
    popd
fi

sudo install -m 644 "${GITROOT}/openwrt-crossbuild-env/motd" /etc/motd
