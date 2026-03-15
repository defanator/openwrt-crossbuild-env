# -*- mode: ruby -*-
# vi: set ft=ruby :

$bootstrap_script = <<-'EOF'
set -ex
cp -r /vagrant/Makefile /vagrant/bootstrap.sh /vagrant/ci /vagrant/motd /vagrant/requirements.txt /home/vagrant/
/home/vagrant/bootstrap.sh
make venv
EOF

Vagrant.configure("2") do |config|
  mem  = 1024
  host = RbConfig::CONFIG['host_os']

  # use one quarter of available cores, rounded down to an even number
  cores_total = `getconf _NPROCESSORS_ONLN`.to_i
  cores_desired = [(cores_total / 4) & ~1, 2].max
  cpus = [cores_desired, cores_total].min

  # use N*1Gb of RAM where N equals allocated number of CPU cores,
  # or half of all available RAM (whichever is less)
  if host =~ /darwin/
    mem = [cpus * 1024, `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2].min
  elsif host =~ /linux/
    mem = [cpus * 1024, `awk '/MemTotal/ {print $2}' /proc/meminfo`.to_i / 1024 / 2].min
  end

  config.ssh.forward_agent = true

  config.vm.disk :disk, size: "15GB", primary: true

  config.vm.provider "virtualbox" do |vbox, override|
    override.vm.box = "cloud-image/debian-13"
    override.vm.provision "shell", inline: "sudo usermod -s /bin/bash vagrant", before: :all
    vbox.cpus = cpus
    vbox.memory = mem
    vbox.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  config.vm.provider :libvirt do |libvirt, override|
    override.vm.box = "cloud-image/debian-13"
    override.vm.provision "shell", inline: "sudo usermod -s /bin/bash vagrant", before: :all
    libvirt.cpus = cpus
    libvirt.memory = mem
    libvirt.driver = "kvm"
    libvirt.cpu_mode = "host-passthrough"
  end

  config.vm.provider "vmware_desktop" do |vmw, override|
    override.vm.box = "defanator/debian-13"
    vmw.cpus = cpus
    vmw.memory = mem
    vmw.gui = false
    vmw.linked_clone = false
  end

  config.vm.provision "shell", inline: $bootstrap_script, privileged: false

  config.vm.define "builder", autostart: true do |builder|
  end
end
