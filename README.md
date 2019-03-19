# workstation-bootstrap

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)

#### Table of Contents

1. [Important Notice About Version 3.0.0](#important-notice-about-version-300)
2. [Overview](#overview)
    * [Warning](#warning)
3. [Prerequisites](#prerequisites)
    * [General](#general)
	* [Arch Linux](#arch-linux)
4. [Customization](#customization)
    * [Hiera Data](#hiera-data)
    * [Sensitive Information](#sensitive-information)
5. [Setup](#setup)
6. [Usage](#usage)
7. [Reference](#reference)
    * [site.pp manifests](#site.pp-manifest)
    * [Puppetfile](#puppetfile)
    * [workstation_bootstrap module](#workstation_bootstrap-module)
    * [Hiera](#hiera)
    * [Hiera Ordering](#hiera-ordering)
8. [Testing](#testing)

## Important Notice About Version 3.0.0

Versions 2.0.0 and earlier of this repository were a full [control repository](https://puppet.com/docs/pe/latest/code_management/control_repo.html) setup for environments and intended to be checked out into the distribution default Puppet config directories (i.e. ``/etc/puppet/code``). I've found this to be cumbersome, unusual, and difficult to maintain. As a result, Version 3.0.0 changes this repository to run directly from the git clone in the way that masterless Puppet provisioners are typically used. Hopefully this will make it easier for others to use as an example.

## Overview

This is an example of a puppet / [r10k](https://github.com/puppetlabs/r10k) masterless repository for use with my [archlinux_workstation](https://forge.puppet.com/jantman/archlinux_workstation) and optionally [archlinux_macbookretina](https://forge.puppet.com/jantman/archlinux_macbookretina) Puppet modules. This specific repository includes some personal configuration of mine, and is intended to be forked and modified as described below. This is intended to be a generic framework for anyone who wants to use Puppet to manage their workstation's configuration. The project provides some sane (though opinionated) defaults, and instructions for how to change them. The defaults are geared towards Arch Linux, but the core in this repository can be used for any distribution, or just as an example/starting point.

In general, what this repository has is:

* a [Puppetfile](#puppetfile) for use with r10k, to install all dependencies.
* a [site.pp main manifest](#site.pp-manifest), which sets up the top-scope things needed for [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall)) and uses your [hiera data](#hiera) to include the classes you want to use.
* Some helper scripts under ``bin/`` to aid in use. See [Setup](#setup) and [Usage](#usage).
* Documentation on initial setup of an Arch computer to use with this repo.

### Warning

__WARNING__: If you run this project unmodified on an existing machine, it WILL do very bad things. It's recommended that you:

1. Run this on a brand new machine, and review all upstream changes before running again.
2. Carefully review the defaults to determine if they're acceptable to you.

## Prerequisites

### General

To use this, you'll need:

* A working Linux install (this repo is geared towards Arch)
* ``puppet`` (whatever version Arch ships, usually the latest release), [r10k](https://github.com/adrienthebo/r10k) (see below) and ``git`` installed
* A text editor of your choice (usable without a GUI / X environment)

Distro-specific instructions follow.

### Arch Linux

1. Do a default, base install of Arch (i.e. see instructions in the [Arch Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide), or my personal install notes in [phoenix_install.md](https://github.com/jantman/workstation-bootstrap/blob/master/phoenix_install.md), [jackiepc_install.md](https://github.com/jantman/workstation-bootstrap/blob/master/jackiepc_install.md), [macbookpro11,4_install.md](https://github.com/jantman/workstation-bootstrap/blob/master/macbookpro11,4_install.md), or [precision5530_install.md](https://github.com/jantman/workstation-bootstrap/blob/master/precision5530_install.md)).
2. If you're on a HiDPI display like a MacBook Retina, you may want to increase the console font size, i.e. ``setfont sun12x22``
2. Find your network interface name (``ip addr``) and get DHCP: ``systemctl start dhcpcd@<interface name>``, or get connectivity howerver else you want. You should now have an IP address, and networking should work (i.e. ``ping www.google.com``).
3. If desired, ``pacman -S openssh && systemctl start sshd`` so you can work remotely.
4. Make sure everything is up to date: ``pacman -Syu``
5. Install Puppet and some packages required to build ruby things: ``pacman -S base-devel puppet git lsb-release ruby``
6. Install r10k. It's currently not in an official Arch package; to get the latest version, use ``gem install --no-user-install r10k``
7. If you're going to be using private puppet module(s), setup SSH keys for the root user and add them to your GitHub account (either as keys for your user, or deploy keys on the repository).

## Customization

Here's how to make this project do what you want:

1. Fork this repository.
2. Edit ``Puppetfile`` to contain all of the modules that you need as well as their dependencies. Unlike ``puppet module install``, r10k does not have dependency resolution.
3. Edit the files under ``hiera/`` to do what you need. See below for more information.
4. Edit ``manifests/site.pp`` as needed, though the default should be acceptable for most people.
5. Edit the spec tests under ``spec/hosts`` to match your changes in the previous steps.
6. Commit and push your changes.

The [Reference](#reference) section below describes what this project provides by default, what you _have_ to change, and some of the common things you may want to change.

### Hiera Data

Aside from the list of modules you require in your Puppetfile, the rest of the configuration resides in Hiera data, including the list of classes to apply to each node. This makes it easier to separate the upstream code for this repository from your own configuration.

In addition to the usual binding of values to keys (class parameters), the Hiera data also determines which classes to apply based on the values in the ``classes`` and ``remove_classes`` arrays. These are utilized in ``site.pp``. The ``classes`` and ``remove_classes`` arrays are pulled in using Array merging, meaning that rather than stopping at the first instance found in the hierarchy, Hiera/Puppet will merge all instances of the respective arrays from all data sources into one. The ``classes`` array determines the classes that will be applied to a node; any classes in ``remove_classes`` will be removed from the final ``classes`` list before applying to the node.

If you're OK with the defaults (such as my [archlinux_macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina) module on Arch Linux MacBooks and
[archlinux_workstation](https://github.com/jantman/puppet-archlinux-workstation) on any Arch Linux machine), you should only need to update the values in ``user_config.yaml``.

If you want to remove my ``archlinux_macbookretina`` module, for example, add the following to ``user_config.yaml``:

```
remove_classes:
  - archlinux_macbookretina
```

### Sensitive Information

Most users will have some sensitive information that they want on their machine (SSH keys, API credentials, personal information) and don't want in a public GitHub repository. There are three simple methods of handling this:

1. Create a puppet module in a private GitHub repository that contains your sensitive configuration, dotfiles, etc. This is how I manage my personal configuration (hence the references to my 'privatepuppet' module).
2. Manage your user-specific information in a puppet module that's stored locally (and deployed however you want), using r10k's [local module](https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#local) support.
3. Duplicate your fork of the upstream repository and make it private. This is the last option, as it makes it more difficult to pull in upstream changes or see what's changed upstream since you created the fork.

## Setup

To set up the project on one of your own machines:

1. ``git clone https://github.com/jantman/workstation-bootstrap.git`` (or your fork, if you made one) somewhere convenient; I use ``/root`` for ease.
2. ``cd workstation-bootstrap``
3. To deploy the dependencies with r10k and then run Puppet: ``./bin/run_r10k_puppet.sh``. Assuming you're running under Arch Linux and using my [archlinux_workstation](https://github.com/jantman/puppet-archlinux-workstation) module, you'll want to do this either in a screen session or redirect the output to a file; at some point in the run, Xorg and SDDM will start up and your display will turn graphical. You can either login or use ``Ctrl + Alt + F2`` to get to a text console. If puppet dies when the ``sddm`` service starts, just re-run it.
4. After the initial run, set the password for your newly-created user and then reboot.
5. Log in as your user.

## Usage

* To run the r10k deploy, ``./bin/run_r10k.sh``
* To run puppet on ``site.pp``, ``./bin/run_puppet.sh``
* To run r10k and then puppet, ``./bin/run_r10k_puppet.sh``

``./bin/run_puppet.sh`` and ``./bin/run_r10k_puppet.sh`` will add any command-line arguments that you specify to the ``puppet`` command before the path to ``site.pp`` (i.e. ``./bin/run_r10k_puppet.sh --noop`` will end run ``puppet`` with ``--noop``).

I generally create symlinks in ``~/bin`` to these scripts for ease.

## Firewall Rules and Docker

The pre-1.0.0 behavior of this module was to include a global firewall resource purge, to remove all unmanaged iptables rules:

```
resources { 'firewall':
  purge => true
}
```

However, if you were running Docker (even configured via Puppet), this would purge all of the Docker-added iptables rules, and break Docker networking.

A workaround for this is to set ``firewall_purge: false`` in your ``user_config.yaml``. This will disable global purging of rules, and you will need to configure purging on a per-chain basis in your own code, with the [fireallchain](https://forge.puppet.com/puppetlabs/firewall/1.8.0/types#firewallchain) type. An example of this that's safe for Docker is only purging the IPv4 INPUT and OUTPUT chains:

```
firewallchain {'INPUT:filter:IPv4':
  ensure => present,
  purge  => true,
}

firewallchain {'OUTPUT:filter:IPv4':
  ensure => present,
  purge  => true,
}
```

## Reference

### site.pp manifest

``site.pp`` contains the code which must be run in a top scope.

At this moment, what this code does is:

* Setup for the [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module as documented in its readme.
* Include classes via Hiera data.

### workstation_bootstrap module

The base ``workstation_bootstrap`` module can be found in ``modules/local/workstation_bootstrap``. It has two classes, ``workstation_bootstrap::firewall_pre`` and ``workstation_bootstrap::firewall_post``, which
do setup of default Firewall module rules, including accepting SSH on port 22.

### Puppetfile

See [Puppetfile](Puppetfile) itself for the current list of included dependencies.

By default, the Puppetfile also includes my personal "privatepuppet" module. You should comment this out or replace it with your own personal module(s).

### Hiera

The Hiera hierarchy used is rooted at ``hiera/`` and has configurations as follows:

* ``defaults.yaml`` - default configuration and classes
* ``osfamily/Archlinux.yaml`` - include ``archlinux-workstation`` class on Arch Linux
* ``osfamily_productname/Archlinux_MacBookPro10,1.yaml`` and ``osfamily_productname/Archlinux_MacBookPro11,4.yaml`` - include ``archlinux_macbookretina``
* ``user_config.yaml`` - user-specific settings, such as your login username, and preference-related configuration; ideally, this should be the only file changed by users customizing this project

## Testing

There are unit tests using rspec-puppet. See the ``Rakefile``, and ``.travis.yml`` for an example of running them.
