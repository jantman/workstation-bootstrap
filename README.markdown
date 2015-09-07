# workstation-bootstrap

__Note__ - This project is currently undergoing a major overhaul. Stay tuned.

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)

####Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
    * [General](#general)
	* [Arch Linux](#arch-linux)
3. [Customization](#customization)
    * Hiera Data
4. [Setup](#setup)
5. [Usage](#usage)
6. [Reference](#reference)
    * workstation-bootstrap module
    * Puppetfile
    * Hiera
7. [Testing](#testing)

##Overview

This is my example of [r10k](https://github.com/adrienthebo/r10k)-based Puppet management for my personal workstations (desktop and laptop).
It aims to let me configure my personal boxes with Puppet, and maintain more or less the same environment (installed packages,
configuration) on both/all of them.

This is intended to be a generic framework for anyone who wants to use Puppet to manage their workstation's configuration. The project
provides some sane (though opinionated) defaults, and instructions for how to override them. The defaults are  geared towards Arch
Linux, but the core in this repository can be used for any distribution, or just as an example/starting point.

The general concept is that this repository holds a [Puppetfile](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd) for
use with r10k, a ``site.pp`` main manifest (currently just used to setup the top-scope things needed for
[puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall)), your [Hiera](http://docs.puppetlabs.com/hiera/latest/) data,
and some support scripts to keep things running smoothly.

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
2. ``dhcpcd <interface name>`` to get minimally-working DHCP, or whatever you want to do to get connectivity to the outside world.
3. if desired, ``pacman -S openssh && systemctl start sshd`` so you can work remotely
4. Make sure everything is up to date: ``pacman -Syu``
5. Install Puppet and some packages required to build ruby things: ``pacman -S base-devel puppet git lsb-release``
6. Install r10k. It's currently not in the Arch packages repo or included in the Arch puppet package; for the time being,
   you can find the PKGBUILDs that I use for r10k and its dependencies in my [arch-pkgbuilds](https://github.com/jantman/arch-pkgbuilds) repo.
7. If you're going to be using a private puppet module, setup SSH keys for the root user and add them to your GitHub account (either as keys
   for your user, or deploy keys on the repository).

##Customization

Here's how to make this project do what you want:

1. Fork this repository. Make sure that the "production" branch is the primary branch.
2. Edit ``puppet/Puppetfile`` to contain all of the modules that you need.
3. Edit the files under ``puppet/hiera/`` to do what you need. See below for more information.
4. Commit and push your changes.

See the [Reference](#reference) section below for what this module currently does.

###Hiera Data

##Setup

To set up the project on one of your own machines:

1. ``cd /etc/puppetlabs/puppet``
2. ``git clone https://github.com/jantman/workstation-bootstrap.git workstation-bootstrap`` (or your fork, if you made one)
3. ``cd workstation-bootstrap``
4. ``./setup.sh``
5. Deploy the modules with r10k: ``./deploy.sh``
6. Run puppet: ``./run_puppet.sh``

##Reference

###workstation-bootstrap module

The entirety of the puppet code for the ``workstation-bootstrap`` module lives in ``puppet/manifests/site.pp`` in this repository.

Currently what it does is:

* Setup for the [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module as documented in its readme.

###Puppetfile

###Hiera

TODO - document what the defaults for the module do. Also mention the included modules like [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina) and [puppet-archlinux-workstation](https://github.com/jantman/puppet-archlinux-workstation).

##Testing

A ``Vagrantfile`` is provided that spins up an Arch Linux VM with puppet installed, suitable for testing your configuration.
