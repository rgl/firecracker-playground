#!/bin/bash
set -euxo pipefail

# see https://hub.docker.com/_/alpine/tags
# renovate: datasource=docker depName=alpine extractVersion=^(?<version>[0-9]+(\.[0-9]+)+)$
alpine_version='3.18.4'

# create the alpine rootfs.
# see https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md
# see https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md
# see https://hub.docker.com/_/alpine
umount /tmp/firecracker-vm-alpine-rootfs 2>/dev/null || true
if [ -e /tmp/firecracker-vm-alpine-rootfs ]; then
    rmdir /tmp/firecracker-vm-alpine-rootfs
fi
rm -f /tmp/firecracker-vm-alpine-rootfs.ext4
install -m 700 -d /tmp/firecracker-vm-alpine-rootfs
install -m 600 /dev/null /tmp/firecracker-vm-alpine-rootfs.ext4
truncate --size 128M /tmp/firecracker-vm-alpine-rootfs.ext4
mkfs.ext4 -F /tmp/firecracker-vm-alpine-rootfs.ext4
mount /tmp/firecracker-vm-alpine-rootfs.ext4 /tmp/firecracker-vm-alpine-rootfs
nerdctl run -i --rm -v /tmp/firecracker-vm-alpine-rootfs:/rootfs "alpine:$alpine_version" <<'EOF'
set -euxo pipefail

# set the root password.
echo 'root:root' | chpasswd

# disable the virtual login terminals.
sed -i -E 's/^(tty\d+:.+)/#\1/g' /etc/inittab

# enable the serial port login terminal.
sed -i -E 's/^#(ttyS0:.+)/\1/g' /etc/inittab

# install the required packages.
apk add openrc
apk add util-linux

# on boot, mount the required filesystems.
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot

# install into rootfs.
for d in bin etc lib root sbin usr; do
    tar c "/$d" | tar x -C /rootfs
done
for d in dev proc run sys var; do
    install -d "/rootfs/$d"
done
EOF
umount /tmp/firecracker-vm-alpine-rootfs
rmdir /tmp/firecracker-vm-alpine-rootfs
dumpe2fs /tmp/firecracker-vm-alpine-rootfs.ext4
