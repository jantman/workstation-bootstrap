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
    * [Sensitive Information](#sensitive-information)
4. [Setup](#setup)
5. [Usage](#usage)
6. [Reference](#reference)
    * [site.pp manifests](#site.pp-manifest)
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
[puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall)),
your [Hiera](http://docs.puppetlabs.com/hiera/latest/) data, and some support scripts to set things up and keep them running
smoothly. You simply need to modify the Puppetfile and Hiera data and start using it!

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
2. If you're on a HiDPI display like a MacBook Retina, you may want to increase the console font size, i.e. ``setfont sun12x22``
2. ``dhcpcd <interface name>`` to get minimally-working DHCP, or whatever you want to do to get connectivity to the outside world.
3. if desired, ``pacman -S openssh && systemctl start sshd`` so you can work remotely
4. Make sure everything is up to date: ``pacman -Syu``
5. Install Puppet and some packages required to build ruby things: ``pacman -S base-devel puppet git lsb-release``
6. Install r10k. It's currently not in the Arch packages repo or included in the Arch puppet package; for the time being,
you can find the PKGBUILDs that I use for r10k and its dependencies in my [arch-pkgbuilds](https://github.com/jantman/arch-pkgbuilds) GitHub
repo, or you can use my built packages via the following pacman repo configuration (append to the end of ``/etc/pacman.conf``):
```
[jantman]
SigLevel = Never
Server = http://archrepo.jasonantman.com/current
```
7. If you're going to be using a private puppet module, setup SSH keys for the root user and add them to your GitHub account (either as keys for your user, or deploy keys on the repository).

##Customization

Here's how to make this project do what you want:

1. Fork this repository. Make sure that the "production" branch is the primary branch.
2. Edit ``puppet/Puppetfile`` to contain all of the modules that you need.
3. Edit the files under ``puppet/hiera/`` to do what you need. See below for more information.
4. Commit and push your changes.

The [Reference](#reference) section below describes what this project provides by default, what you _have_ to change, and some of the common things you may want to change.

###Hiera Data

Aside from the list of modules you require in your Puppetfile, the rest of the configuration resides in Hiera data, including the list of classes to apply to each node. This makes it easier to separate the upstream code for this repository from your own configuration.

In addition to the usual binding of values to keys (class parameters), the Hiera data also determines which classes to apply based on the values in the ``classes`` and ``exclude_classes`` arrays. These are utilized in ``site.pp``. The ``classes`` and ``exclude_classes`` arrays are pulled in using Array merging, meaning that rather than stopping at the first instance found in the hierarchy, Hiera/Puppet will merge all instances of the respective arrays from all data sources into one. The ``classes`` array determines the classes that will be applied to a node; any classes in ``exclude_classes`` will be removed from the final ``classes`` list before applying to the node.

If you're OK with the defaults (such as my [archlinux_macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina) module on Arch Linux MacBooks and
[archlinux_workstation](https://github.com/jantman/puppet-archlinux-workstation) on any Arch Linux machine), you should only need to update the values in ``user_config.yaml``.

If you want to remove my ``archlinux_macbookretina`` module, for example, add the following to ``user_config.yaml``:

```
exclude_classes:
  - archlinux_macbookretina
```

###Sensitive Information

Most users will have some sensitive information that they want on their machine (SSH keys, API credentials, personal information) and don't want in a public GitHub repository. There are three simple methods of handling this:

1. Create a puppet module in a private GitHub repository that contains your sensitive configuration, dotfiles, etc. This is how I manage my personal configuration (hence the references to my 'privatepuppet' module).
2. Manage your user-specific information in a puppet module that's stored locally (and deployed however you want), using r10k's [local module](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#local) support.
3. Duplicate your fork of the upstream repository and make it private. This is the last option, as it makes it more difficult to pull in upstream changes or see what's changed upstream since you created the fork.

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

###site.pp manifest

``site.pp`` contains the entirety of the code for the ``workstation-bootstrap`` module, which must be evaluated in top-scope.

At this moment, what this code does is:

* Setup for the [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module as documented in its readme.
* Declare the ``firewall``, ``workstation-bootstrap::firewall_pre`` and ``workstation-bootstrap::firewall_post`` classes for default firewall rules.
* Include classes via Hiera data.

###Puppetfile

* [archlinux_workstation](https://github.com/jantman/puppet-archlinux-workstation)
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [saz/sudo](https://forge.puppetlabs.com/saz/sudo) (dependency of archlinux_workstation)
* [saz/ssh](https://forge.puppetlabs.com/saz/ssh) (dependency of archlinux_workstation)
* [puppetlabs/firewall](https://forge.puppetlabs.com/puppetlabs/firewall)
* [puppetlabs/inifile](https://forge.puppetlabs.com/puppetlabs/inifile)
* [puppetlabs/vcsrepo](https://forge.puppetlabs.com/puppetlabs/vcsrepo)
* [eirc/single_user_rvm](https://forge.puppetlabs.com/eirc/single_user_rvm)
* [nanliu/staging](https://forge.puppetlabs.com/nanliu/staging)

By default, the Puppetfile also includes my personal "privatepuppet" module. You should comment this out or replace it with your own personal module(s).

###Hiera

The Hiera hierarchy used is as follows:

* ``defaults.yaml`` - default configuration and classes
* ``os.family/Archlinux.yaml`` - include ``archlinux-workstation`` class on Arch Linux
* ``os.family_productname/Archlinux_MacBookPro10,1.yaml`` - include ``
* ``user_config.yaml`` - user-specific settings, such as your login username, and preference-related configuration; ideally, this should be the only file changed by users customizing this project

##Testing

A ``Vagrantfile`` is provided that spins up an Arch Linux VM with puppet installed, suitable for testing your configuration.
