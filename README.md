# OpenWrt cross-build environment

[![build kernels](https://github.com/defanator/openwrt-crossbuild-env/actions/workflows/build-kernels.yml/badge.svg)](https://github.com/defanator/openwrt-crossbuild-env/actions/workflows/build-kernels.yml)

This repository provides a virtualized cross-compilation environment for OpenWrt development. It includes a few helpers to get a complete OpenWrt build system, automated setup scripts, and CI configuration to build OpenWrt kernel, packages, and firmware images across multiple target architectures in a consistent, reproducible environment.

## Quick start - local environment

### Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- virtualization provider: [VMware Fusion](https://www.vmware.com/products/fusion.html) (macOS), [VMware Workstation](https://www.vmware.com/products/workstation-pro.html) (Windows/Linux), [VirtualBox](https://www.virtualbox.org/) (multiple platforms), or [libvirt](https://libvirt.org) (Linux)

### Getting started

1. Bring up the Vagrant environment:
   ```bash
   make up
   ```

2. SSH into the builder VM:
   ```bash
   vagrant ssh
   ```

3. List available targets, show default environment:
   ```bash
   make
   make show-env
   ```

4. Prepare build environment for a given OpenWrt release/target:
   ```
   make prepare
   make fix-host-symlinks
   ```

5. Build OpenWrt kernel:
   ```
   make build-kernel
   ```

Refer to [Makefile.crossbuild](Makefile.crossbuild) for `OPENWRT_*` variables available to select specific OpenWrt release and target configurations. The [direnv](https://direnv.net) could be handy to keep these variables under your building directory.

## Quick start - GitHub actions

Refer to the workflows of the following projects to see how this environment can be plugged in:
 - https://github.com/defanator/openwrt-loki-exporter
 - https://github.com/defanator/amneziawg-openwrt

# History

Initially created while working on the MIPS IPsec modules:
https://github.com/defanator/mcespi

Perhaps it could be useful for other activities in regards to OpenWrt development.
