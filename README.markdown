# workstation-bootstrap

__Note__ - This project is currently undergoing a major overhaul. Stay tuned.

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)

####Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
    * [General](#general)
	* [Arch Linux](#arch-linux)
3. [Reference](#reference)
4. [Customization](#customization)
5. [Setup](#setup)
6. [Usage](#usage)

##Overview

This is my [r10k](https://github.com/adrienthebo/r10k)-based Puppet management tool for my personal workstations (desktop and laptop).
It aims to let me configure my personal boxes with Puppet, and maintain more or less the same environment (installed packages,
configuration) on both/all of them.

This is intended to be a generic framework for anyone that wants to use Puppet to manage their workstation's configuration. The project
provides some sane (though somewhat opinionated) defaults, and instructions for how to override them. It's mainly geared towards Arch
Linux, but can be used for any distribution with some changes.

The general concept is that this repository, managed by r10k, provides some general defaults (such as my archlinux-macbookretina
module on my MacBook Retina) and whatever other public modules are needed, as well as applying a private module for anything
user-specific or sensitive.

For information about everything this module does, see [Reference](#reference).

##Prerequisites

###General

To use this, you'll need:

* A working OS install
* ``puppet``, [r10k](https://github.com/adrienthebo/r10k) and ``git`` installed
* A text editor of your choice (usable without a GUI / X environment)

Distro-specific instructions follow.

###Arch Linux

1. Do a default, base install of Arch (i.e. see instructions in
   [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina)
   or the [Arch Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide), or
   [phoenix_install.md](phoenix_install.md) documenting my latest desktop machine build/install).
2. ``dhcpcd <interface name>`` to get minimally-working DHCP.
3. ``pacman -S openssh && systemctl start sshd`` so you can work remotely...
4. Make sure everything is up to date: ``pacman -Syu``
5. Install Puppet and some packages required to build ruby things: ``pacman -S base-devel puppet git lsb-release``
7. Install r10k via yaourt: ``yaourt -S ruby-r10k``. If yaourt installed ``ruby-cri``, and r10k still
   requires 2.4.0, you'll need to install it: ``gem install cri -v 2.4.0``.
8. Install a text editor of your choice (i.e. ``vim``, ``emacs``, etc.)
9. If you're going to be using a private puppet module, setup SSH keys for the root user and add them to your GitHub account.

##Reference

This details the actions that this module takes, by default. To use it, follow the [Customization](#customization)
instructions below.

* Define an instance of my [archlinux_workstation](https://github.com/jantman/puppet-archlinux-workstation) module on
  any node where ::osfamily is 'Archlinux'
* Define an instance of my "privatepuppet" module on every node (which you should either remove, or replace with your
  own private module for sensitive stuff).

##Customization

1. Fork this repository. Make sure that the "production" branch is the primary branch.
2. Edit the files under ``manifests/`` to do what you want. The majority of configuration is triggered by
   ``manifests/site.pp``, which I use to pull in default bits of configuration, plus distro- and hardware-specific
   bits. Most importantly, edit the "configuration" block in site.pp to have the correct username, etc.
3. Add or remove modules in the ``Puppetfile`` as necessary, replacing ``jantman/privatepuppet`` with
   your own private puppet module, if needed.
4. Use as per the Usage instructions below.

##Setup

1. ``cd /etc/puppetlabs/puppet``
2. ``git clone https://github.com/jantman/workstation-bootstrap.git workstation-bootstrap`` (or your fork, if you made one)
3. ``cd workstation-bootstrap``
4. ``./setup.sh``

This mainly follows the r10k documentation and [jtopjian's post](http://terrarum.net/administration/puppet-infrastructure-with-r10k.html).

1. In the "main" section of ``/etc/puppet/puppet.conf``,
   set ``modulepath = $confdir/environments/$environment/modules:$confdir/environments/$environment/``
   and ``manifest = $confdir/environments/$environment/manifests/site.pp``
2. Create ``/etc/r10k.yaml`` with the following contents, replacing ``https://github.com/jantman/workstation-bootstrap``
   with the URL to your fork.

```
---
:cachedir: /var/cache/r10k
:sources:
  :local:
    remote: https://github.com/jantman/workstation-bootstrap
    basedir: /etc/puppet/environments
```

3. If you have any private modules (or use GitHub modules over git/ssh in your Puppetfile), generate
   a SSH keypair for root on your new machine, and add them as deploy keys for your repository.
4. Do the first/initial r10k run to pull in all of the correct modules: ``r10k deploy environment -p``

Usage
-----

1. ``alias puppetize='r10k deploy environment -p; puppet apply --verbose /etc/puppetlabs/code/environments/production/manifests/site.pp'``
2. ``puppetize``
3. Iterate as needed. Re-run occasionally.
4. If you don't make any root (or outside your homedir) changes outside of puppet, ever,
   you'll always be able to rebuild your machine after failure or when you get a new one.
   Now you can finally stop backing up everything but your homedir (and your github, of course...).

Testing
--------

A ``Vagrantfile`` is provided that spins up an Arch Linux VM with puppet installed, suitable for testing.
