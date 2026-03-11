# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  mem  = 1024
  host = RbConfig::CONFIG['host_os']

  # use one quarter of available cores, rounded down to an even number, capped at 2 CPUs (if available)
  cores = `getconf _NPROCESSORS_ONLN`.to_i
  cpus = [2, [(cores / 4) * 2, 1].max].min

  if host =~ /darwin/
    mem = [4096, `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2].max
  elsif host =~ /linux/
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

  config.vm.provider "vmware_desktop" do |vmw, override|
    vmw.cpus = cpus
    vmw.memory = mem
    vmw.gui = false
    vmw.linked_clone = false
  end

  config.vm.disk :disk, size: "15GB", primary: true

  config.vm.provision "file",
    source: "Makefile",
    destination: "/home/vagrant/Makefile"

  config.vm.provision "file",
    source: "bootstrap.sh",
    destination: "/home/vagrant/bootstrap.sh"

  config.vm.provision "file",
    source: "motd",
    destination: "/home/vagrant/motd"

  config.vm.provision "shell",
    path: "bootstrap.sh",
    privileged: false

  config.vm.define "builder", autostart: true do |builder|
    builder.vm.box = "defanator/debian-13"
  end
end
