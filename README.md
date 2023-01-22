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

# start a vm in foreground.
ip tuntap add tap0 mode tap
ip addr add 172.18.0.1/24 dev tap0
#sysctl -w net.ipv4.conf.tap0.proxy_arp=1 >/dev/null
sysctl -w net.ipv6.conf.tap0.disable_ipv6=1 >/dev/null
ip link set tap0 up
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT
KERNEL_DEFAULT_OPTS='ro console=ttyS0 noapic reboot=k panic=1 pci=off nomodules'
KERNEL_OPTS="${KERNEL_OPTS} random.trust_cpu=on"
KERNEL_OPTS="${KERNEL_OPTS} ip=172.18.0.2::172.18.0.1:255.255.255.0::eth0:off"
firectl \
  --kernel=/tmp/firecracker-vm-alpine-vmlinux.bin \
  --kernel-opts="$KERNEL_OPTS" \
  --root-drive=/tmp/firecracker-vm-alpine-rootfs.ext4 \
  --tap-device=tap0/aa:bb:cc:00:00:00
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
