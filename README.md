# About

My [Firecracker](https://github.com/firecracker-microvm/firecracker) playground.

# Usage

Install the [Base Ubuntu 22.04 Box](https://github.com/rgl/ubuntu-vagrant).

Launch the environment:

```bash
vagrant up --provider=libvirt --no-destroy-on-error --no-tty
```

Start an example VM:

```bash
# login into the vagrant created VM.
vagrant ssh linux

# switch to root.
sudo -i

# setup the host network.
ip tuntap add tap0 mode tap
ip addr add 172.18.0.1/24 dev tap0
#sysctl -w net.ipv4.conf.tap0.proxy_arp=1 >/dev/null
sysctl -w net.ipv6.conf.tap0.disable_ipv6=1 >/dev/null
ip link set tap0 up
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT

# setup the read-only base disk loop device.
base_disk_loop_device="$(losetup --find --show /tmp/firecracker-vm-alpine-rootfs.ext4 --read-only)"
base_disk_loop_device_size="$(blockdev --getsz /tmp/firecracker-vm-alpine-rootfs.ext4)"

# create the temporary vm disk as a copy-on-write (cow) device.
rm -f /tmp/firecracker-vm-alpine0.cow.lvm
install -m 600 /dev/null /tmp/firecracker-vm-alpine0.cow.lvm
truncate --size 128M /tmp/firecracker-vm-alpine0.cow.lvm
root_disk_loop_device="$(losetup --find --show /tmp/firecracker-vm-alpine0.cow.lvm)"
echo "0 $base_disk_loop_device_size snapshot $base_disk_loop_device $root_disk_loop_device p 4" \
  | dmsetup create firecracker-vm-alpine0
losetup
dmsetup table
du -h /tmp/firecracker-vm-alpine0.cow.lvm

# start a vm in foreground.
# NB you can login into the vm as root:root.
# NB to shutdown the vm, use the reboot command or send an sigint to the
#    firectl (or the firecracker) process.
KERNEL_DEFAULT_OPTS='ro console=ttyS0 noapic reboot=k panic=1 pci=off nomodules'
KERNEL_OPTS="${KERNEL_OPTS} random.trust_cpu=on"
KERNEL_OPTS="${KERNEL_OPTS} ip=172.18.0.2::172.18.0.1:255.255.255.0::eth0:off"
firectl \
  --kernel=/tmp/firecracker-kernel.bin \
  --kernel-opts="$KERNEL_OPTS" \
  --root-drive=/dev/mapper/firecracker-vm-alpine0 \
  --tap-device=tap0/aa:bb:cc:00:00:00

# destroy the temporary vm disk.
dmsetup remove firecracker-vm-alpine0
losetup --detach "$root_disk_loop_device"
du -h /tmp/firecracker-vm-alpine0.cow.lvm
rm -f /tmp/firecracker-vm-alpine0.cow.lvm

# detach the base disk.
losetup --detach "$base_disk_loop_device"
```

List this repository dependencies (and which have newer versions):

```bash
export GITHUB_COM_TOKEN='YOUR_GITHUB_PERSONAL_TOKEN'
./renovate.sh
```

# References

* [Getting Started](https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md)
* [rootfs and kernel setup](https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md)
* [Document Firecracker Entropy Approach and Practical Use](https://github.com/firecracker-microvm/firecracker/issues/663)
* [Firecracker: start a VM in less than a second](https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second/)
