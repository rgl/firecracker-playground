ENV["VAGRANT_NO_PARALLEL"]  = "yes"
ENV["VAGRANT_EXPERIMENTAL"] = "typed_triggers"

CONFIG_DNS_DOMAIN      = "test"
CONFIG_REGISTRY_DOMAIN = "registry.#{CONFIG_DNS_DOMAIN}"

VM_LINUX_MEMORY_MB  = 2*1024
VM_LINUX_CPUS       = 4
VM_LINUX_IP_ADDRESS = "10.0.0.3"

CONFIG_EXTRA_HOSTS = """
#{VM_LINUX_IP_ADDRESS} #{CONFIG_REGISTRY_DOMAIN}
"""

Vagrant.configure("2") do |config|
  config.vm.provider "libvirt" do |lv, config|
    lv.cpu_mode = "host-passthrough"
    lv.nested = true
    lv.keymap = "pt"
  end

  config.vm.define :linux do |config|
    config.vm.box = "ubuntu-22.04-amd64"
    config.vm.hostname = "linux"
    config.vm.provider "libvirt" do |lv, config|
      lv.memory = VM_LINUX_MEMORY_MB
      lv.cpus = VM_LINUX_CPUS
      config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: "4.2", nfs_udp: false
    end
    config.vm.network "private_network", ip: VM_LINUX_IP_ADDRESS, libvirt__forward_mode: "none", libvirt__dhcp_enabled: false
    config.vm.provision "shell", path: "provision-extra-hosts.sh", args: [CONFIG_EXTRA_HOSTS]
    config.vm.provision "shell", path: "provision-base.sh"
    config.vm.provision "shell", path: "provision-certificate.sh", args: [CONFIG_REGISTRY_DOMAIN]
    config.vm.provision "shell", path: "provision-runc.sh"
    config.vm.provision "shell", path: "provision-cni-plugins.sh"
    config.vm.provision "shell", path: "provision-containerd.sh", args: [CONFIG_REGISTRY_DOMAIN]
    config.vm.provision "shell", path: "provision-cri-tools.sh"
    config.vm.provision "shell", path: "provision-buildkit.sh"
    config.vm.provision "shell", path: "provision-nerdctl.sh"
    config.vm.provision "shell", path: "provision-registry.sh", args: [CONFIG_REGISTRY_DOMAIN]
    config.vm.provision "shell", path: "provision-crane.sh"
    config.vm.provision "shell", path: "provision-regctl.sh"
    config.vm.provision "shell", path: "provision-firecracker.sh"
    config.vm.provision "shell", path: "provision-firectl.sh"
    config.vm.provision "shell", path: "provision-firecracker-vm-alpine.sh"
  end
end
