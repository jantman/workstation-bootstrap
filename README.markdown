# workstation-bootstrap

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)

####Table of Contents

1. [Overview](#overview)
    * [Warning](#warning)
2. [Prerequisites](#prerequisites)
    * [General](#general)
	* [Arch Linux](#arch-linux)
3. [Customization](#customization)
    * [Hiera Data](#hiera-data)
    * [User Manifest](#user-manifest)
    * [Sensitive Information](#sensitive-information)
4. [Setup](#setup)
5. [Usage](#usage)
6. [Reference](#reference)
    * [manifests](#manifests)
        * [0_site.pp](#0_site.pp)
        * [1_user.pp](#1_user.pp)
        * [2_hiera_classes.pp](#2_hiera_classes.pp)
    * [Puppetfile](#puppetfile)
    * [Hiera](#hiera)
    * [Hiera Ordering](#hiera-ordering)
7. [Testing](#testing)

##Overview

This is my example of [r10k](https://github.com/adrienthebo/r10k)-based Puppet management for my personal workstations (desktop and laptop).
It aims to let me configure my personal boxes with Puppet, and maintain more or less the same environment (installed packages,
configuration) on both/all of them.

This is intended to be a generic framework for anyone who wants to use Puppet to manage their workstation's configuration. The project
provides some sane (though opinionated) defaults, and instructions for how to change them. The defaults are geared towards Arch
Linux, but the core in this repository can be used for any distribution, or just as an example/starting point.

The general concept is that this repository holds a [Puppetfile](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd) for
use with r10k, a ``site.pp`` main manifest (currently just used to setup the top-scope things needed for
[puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) and to pull in OS-specific classes),
your [Hiera](http://docs.puppetlabs.com/hiera/latest/) data, and some support scripts to keep things running
smoothly and set it up. You simply need to modify the Puppetfile, Hiera data, and ``user.pp`` and start using it!

###Warning

__WARNING__: If you run this project unmodified on an existing machine, it WILL do very bad things. It's recommended that you:

1. Run this on a brand new machine, and review all upstream changes before running again.
2. Carefully review the defaults to determine if they're acceptable to you.

##Prerequisites

###General

To use this, you'll need:

* A working OS install
* ``puppet`` (4x; the current version in the Arch repo), [r10k](https://github.com/adrienthebo/r10k) (see below) and ``git`` installed
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
4. Edit ``puppet/manifests/user.pp``
4. Commit and push your changes.

The [Reference](#reference) section below describes what this project provides by default, what you _have_ to change,
and some of the common things you may want to change.

###Hiera Data

Aside from the modules you require in your Puppetfile and some items in ``user.pp``, the rest of the configuration resides in Hiera data, including the list of
classes to apply to each node. This makes it easier to separate the upstream code for this repository from your own configuration,
though doing so is still a bit of a [kluge](http://www.catb.org/jargon/html/K/kluge.html). See [future](#future) below.

If you're OK with my [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina) and
[puppet-archlinux-workstation](https://github.com/jantman/puppet-archlinux-workstation) modules, you should only need
to touch ``defaults.yaml``, which provides the top-level configuration.

###User Manifest

This file includes some classes conditionally based on OS and hardware. See [manifests](#manifests) below for more information.

###Sensitive Information

Most users will have some sensitive information that they want on their machine (SSH keys, API credentials,
personal information) and don't want in a public GitHub repository. There are three simple methods of handling
this:

1. Create a puppet module in a private GitHub repository that contains your sensitive configuration, dotfiles,
etc. This is how I manage my personal configuration (hence the references to my 'privatepuppet' module).
2. Manage your user-specific information in a puppet module that's stored locally (and deployed however you
want), using r10k's [local module](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#local) support.
3. Duplicate your fork of the upstream repository and make it private. This is the last option, as it makes it
   more difficult to pull in upstream changes or see what's changed upstream since you created the fork.

##Setup

To set up the project on one of your own machines:

1. ``cd /etc/puppetlabs/puppet``
2. ``git clone https://github.com/jantman/workstation-bootstrap.git workstation-bootstrap`` (or your fork, if you made one)
3. ``cd workstation-bootstrap``
4. ``./setup.sh``
5. Deploy the modules with r10k and then run Puppet: ``./run_r10k_puppet.sh``

## Usage

* To run the r10k deploy, ``./run_r10k.sh``
* To run puppet on ``site.pp``, ``./run_puppet.sh``
* To run r10k and then puppet, ``./run_r10k_puppet.sh``
* To find the value of a given key in the current Hiera data, ``./hiera_show_value.sh KEY_NAME``

``./run_puppet.sh`` and ``./run_r10k_puppet.sh`` will add any command-line arguments that you specify to the ``puppet`` command before the path to ``site.pp``.

##Reference

###manifests

With the deprecation of Puppet's ``import`` keyword, top-level configuration is defined in a directory of manifests;
running ``puppet apply`` pointing to the directory containing the manifests will [parse all files in the directory](http://docs.puppetlabs.com/puppet/latest/reference/dirs_manifest.html#directory-behavior-vs-single-file)
in alphabetical order - analagous to having a ``site.pp`` and ``include``ing the other files in it.

This project uses a small collection of modules to contain things which must be evaluated in top-scope (like puppetlabs-firewall setup),
include classes via hiera, and wrap conditionals for things that can't be handed in Hiera (like OS- or hardware-specific class includes).

####0_site.pp

``0_site.pp`` contains the top-scope code for the ``workstation-bootstrap`` module.
The entirety of the puppet code for the ``workstation-bootstrap`` module lives in ``puppet/manifests/0_site.pp`` in this repository.

At this moment, what this code does is:

* Setup for the [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module as documented in its readme.
* Declare the ``firewall`, ``workstation-bootstrap::firewall_pre`` and ``workstation-bootstrap::firewall_post`` classes for
default firewall rules.

####1_user.pp

This manifest includes classes based on OS, hardware, and other facts. This mainly exists because of what I consider to be an
oversight in the design of Hiera (see [HI-467](https://tickets.puppetlabs.com/browse/HI-467)); it doesn't handle the ``classes`` key differently, so it's not possible to specify classes
additatively in multiple data files. There's also no way to remove a previously-added class. As a result, while we specify
most of the classes to be applied in ``puppet/hiera/defaults.yaml``, there's no way in Hiera to specify classes to be added
to a node based on OS Family, hardware, or other facts.

This manifest exists to:

1. Add classes to nodes based on specific facts
2. Provide another extension point for user-specific information that must be defined in a top-level manifest.

####2_hiera_classes.pp

This manifest simply contains ``hiera_include('classes')`` to include classes from the Hiera ``classes`` array.

###Puppetfile

TODO - document what's included in the Puppetfile

###Hiera

TODO - document what the default Hiera data does. Also mention the included modules like [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina) and [puppet-archlinux-workstation](https://github.com/jantman/puppet-archlinux-workstation).

##Testing

A ``Vagrantfile`` is provided that spins up an Arch Linux VM with puppet installed, suitable for testing your configuration.
