# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  mem  = 1024
  cpus = 2
  host = RbConfig::CONFIG['host_os']

  if host =~ /darwin/
    mem = [4096, `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2].min
  elsif host =~ /linux/
    cpus = [2, `getconf _NPROCESSORS_ONLN`.to_i / 2].max
    mem = [cpus * 512, `awk '/MemTotal/ {print $2}' /proc/meminfo`.to_i / 1024 / 2].min
  end

  config.vm.provider "virtualbox" do |vbox, override|
    vbox.cpus = cpus
    vbox.memory = mem
  end

  config.vm.provider :libvirt do |libvirt, override|
    libvirt.cpus = cpus
    libvirt.memory = mem
    libvirt.driver = "kvm"
    libvirt.cpu_mode = "host-passthrough"
  end

  config.vm.provision "file",
    source: "bootstrap.sh",
    destination: "/home/vagrant/bootstrap.sh"

  config.vm.provision "file",
    source: "motd",
    destination: "/home/vagrant/motd"

  config.vm.provision "shell",
    path: "bootstrap.sh",
    privileged: false

  config.vm.define "ubuntu1804", autostart: true do |ubuntu1804|
    ubuntu1804.vm.box = "generic/ubuntu1804"
    ubuntu1804.vm.network "private_network", type: "dhcp"
    ubuntu1804.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3
  end
end
