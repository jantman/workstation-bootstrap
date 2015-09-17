# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
/bin/bash -x
# setup my personal repo if it's not already
if ! grep -q jantman /etc/pacman.conf; then
    echo '[jantman]' >> /etc/pacman.conf
    echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
    echo 'Server = http://archrepo.jasonantman.com/current' >> /etc/pacman.conf
fi
# do a full update
pacman -Syu --noconfirm
pacman -S --noconfirm git ruby-r10k
# symlink our code directory
if [[ ! -e /etc/puppetlabs/code/workstation-bootstrap ]]; then
    echo "symlinking /etc/puppetlabs/code/workstation-bootstrap to /vagrant"
    ln -s /vagrant /etc/puppetlabs/code/workstation-bootstrap
fi
SCRIPT

Vagrant.configure(2) do |config|
  # use box from Atlas
  config.vm.box = "jantman/packer-arch-workstation"

  # DHCP'ed private network
  config.vm.network "private_network", type: "dhcp"

  # Forward agent without having to copy private keys
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    # 1G memo
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    # workstation - assume we want a GUI
    vb.gui = true
  end

  config.vm.provision "shell", inline: $script
end
