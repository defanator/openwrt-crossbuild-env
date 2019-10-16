#!/bin/sh

set -ex

cd ${HOME}

sudo apt-get update
sudo apt-get install -y ca-certificates gcc gdb subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip python

curl -LO http://archive.openwrt.org/releases/18.06.1/targets/ar71xx/generic/openwrt-sdk-18.06.1-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64.tar.xz
tar Jvxf openwrt-sdk-18.06.1-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64.tar.xz

echo export STAGING_DIR=\"$HOME/openwrt-sdk-18.06.1-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64/staging_dir\" >> $HOME/.profile
echo PATH=\"$HOME/openwrt-sdk-18.06.1-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64/staging_dir/toolchain-mips_24kc_gcc-7.3.0_musl/bin:$PATH\" >> $HOME/.profile
echo export LC_ALL=C >> $HOME/.profile
echo unset LC_CTYPE >> $HOME/.profile

ifconfig
cat /etc/resolv.conf

git clone https://github.com/defanator/mcespi.git
( cd mcespi && git checkout wip-ar71xx )

git clone https://git.openwrt.org/openwrt/openwrt.git
( cd openwrt && git checkout openwrt-18.06 )

sudo mv motd /etc/
