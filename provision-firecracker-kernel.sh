#!/bin/bash
set -euxo pipefail

firecracker_version="${1:-1.2.0}"
kernel_version="${2:-5.15.93}"
kernel_tarball="linux-$kernel_version.tar.xz"
kernel_major_version="$(echo "$kernel_version" | sed -E 's,([0-9]+)\.([0-9]+)\.([0-9]+),\1,')"
kernel_tarball_url="https://cdn.kernel.org/pub/linux/kernel/v$kernel_major_version.x/$kernel_tarball"
firecracker_kernel_config_filename="microvm-kernel-x86_64-5.10.config"
firecracker_kernel_config_url="https://github.com/firecracker-microvm/firecracker/raw/v$firecracker_version/resources/guest_configs/$firecracker_kernel_config_filename"
nprocs="$(getconf _NPROCESSORS_ONLN)"

# install the build dependencies.
# see https://github.com/rgl/ovmf-secure-boot-vagrant/blob/main/provision-linux.sh
apt-get install -y bc bison flex libssl-dev make libc6-dev libncurses5-dev libelf-dev

# download.
# see https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md
install -d firecracker-kernel
cd firecracker-kernel
wget -qO "$kernel_tarball" "$kernel_tarball_url"
wget -qO "$firecracker_kernel_config_filename" "$firecracker_kernel_config_url"

# build.
# TODO why is this much larger than https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64/kernels/vmlinux.bin?
#      38M vs 21M.
tar xf "$kernel_tarball"
cd "linux-$kernel_version"
install "../$firecracker_kernel_config_filename" .config
make olddefconfig
diff -u "../$firecracker_kernel_config_filename" .config || true
make -j "$nprocs" vmlinux
install vmlinux /tmp/firecracker-kernel.bin
install .config /tmp/firecracker-kernel.config
file /tmp/firecracker-kernel.bin
du -h /tmp/firecracker-kernel.bin
