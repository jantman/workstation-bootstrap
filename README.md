workstation-bootstrap
=====================

This is my [r10k](https://github.com/adrienthebo/r10k)-based Puppet management of my personal boxes (desktop and laptop).
It aims to let me configure my personal boxes with Puppet, and maintain more or less the same environment (installed packages,
configuration) on both/all of them.

The general concept is that this repository, managed by r10k, provides some general defaults (such as my archlinux-macbookretina
module on my MacBook Retina) and whatever other public modules are needed, as well as applying a private module for anything
incredibly specific to me, or sensitive parts of configuration.

Prerequisites
-------------

### General

To use this, you'll need:

* A working OS install
* puppet installed
* the r10k rubygem installed
* git

Distro-specific instructions follow.

### Arch Linux

1. Do a default, base install of Arch (i.e. see instructions in
   [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina)
   or the [Arch Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)).
2. ``dhcpcd <interface name>`` to get minimally-working DHCP.
3. ``pacman -S openssh && systemctl start sshd`` so you can work remotely...
4. ``vi /etc/pacman.conf`` and add the [archlinuxfr](http://archlinux.fr/yaourt-en) repository,
   then ``pacman -Sy yaourt``
5. Make sure everything is up to date: ``pacman -Syu``
6. ``pacman -S base-devel`` for required packages to build puppet, ruby, etc.
7. Install Puppet via yaourt: ``yaourt -S puppet ruby-augeas``
8. Install r10k via yaourt: ``yaourt -S ruby-r10k``

Customization
-------------

1. Fork this repository. Make sure that the "production" branch is the primary branch.
2. Edit the files under ``manifests/`` to do what you want.
3. Add or remove modules in the ``Puppetfile`` as necessary, replacing ``jantman/privatepuppet`` with
   your own private puppet module, if needed.
4. Use as per the Usage instructions below.

Setup
-----

This mainly follows the r10k documentation...

1. In ``/etc/puppet/puppet.conf``, set ``modulepath = $confdir/environments/$environment/modules:$confdir/environments/$environment/``
   and ``manifest = $confdir/environments/$environment/site/manifests/site.pp``

Usage
-----
