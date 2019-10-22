#!/bin/sh

set -ex

OPENWRT_VERSION=18.06.3
OPENWRT_SDK=openwrt-sdk-${OPENWRT_VERSION}-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64.tar.xz
OPENWRT_SDK_URI=http://archive.openwrt.org/releases/${OPENWRT_VERSION}/targets/ar71xx/generic
OPENWRT_SDK_DIR=${OPENWRT_SDK%.tar.xz}

cd ${HOME}

sudo rm -f /etc/resolv.conf
sudo bash <<EOF
echo "nameserver 1.1.1.1" >/etc/resolv.conf
EOF

sudo apt-get update
sudo apt-get install -y ca-certificates gcc gdb subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip python

curl -LO ${OPENWRT_SDK_URI}/${OPENWRT_SDK}
tar Jvxf ${OPENWRT_SDK}

echo export STAGING_DIR=\"${HOME}/${OPENWRT_SDK_DIR}/staging_dir\" >> ${HOME}/.profile
echo PATH=\"${HOME}/${OPENWRT_SDK_DIR}/staging_dir/toolchain-mips_24kc_gcc-7.3.0_musl/bin:$PATH\" >> $HOME/.profile
echo export LC_ALL=C >> $HOME/.profile
echo unset LC_CTYPE >> $HOME/.profile

git clone https://github.com/defanator/mcespi.git
( cd mcespi && git checkout wip-ar71xx )

git clone https://git.openwrt.org/openwrt/openwrt.git
( cd openwrt && git checkout openwrt-18.06 )

sudo mv motd /etc/
