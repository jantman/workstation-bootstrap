# == Class: workstation_bootstrap
#
# Main entry point for workstation_bootstrap project.
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# https://github.com/jantman/workstation-bootstrap/blob/production/manifests/site.pp
#
class workstation_bootstrap {

  #################
  # configuration #
  #################

  $username = 'jantman'

  ###########################################
  # stuff that should be useful to everyone #
  ###########################################

  # Arch-specific stuff
  if $::osfamily == 'Archlinux' {

    class {'archlinux_workstation':
      username  => $username,
    }

    # Arch laptop specific
    if $::type == 'Notebook' or $::type == 'Portable' or $::type == 'LapTop' or $::type == 'Sub Notebook' {
      # nothing yet...
    }
  } # end Arch-specific

  # MacBookPro Retina 10,1-specific
  if $::bios_version =~ /^MBP101.+/ or $::productname == 'MacBookPro10,1' {
    # TODO: https://github.com/jantman/puppet-archlinux-macbookretina
  }

  # Generic stuff for all OSes

  # install RVM and some rubies via eirc/single_user_rvm
  single_user_rvm::install { $username: }
  single_user_rvm::install_ruby { ['ruby-1.8.7', 'ruby-1.9.3', 'ruby-2.0.0']: user => $username, }

  #################################################
  # personal config - probably only useful to me, #
  #  or relatively custom                         #
  #################################################

  # my private stuff
  class {'privatepuppet': }
}

# puppetlabs/firewall - this stuff needs to be
#  done in global/top scope.
resources { 'firewall':
  purge => true
}

class workstation_bootstrap::firewall_pre {
  Firewall {
    require => undef,
  }
  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    ctstate => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }
}

class workstation_bootstrap::firewall_post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}

class { ['workstation_bootstrap::firewall_pre', 'workstation_bootstrap::firewall_post']: }
class { 'firewall': }

Firewall {
  before  => Class['workstation_bootstrap::firewall_post'],
  require => Class['workstation_bootstrap::firewall_pre'],
}
# END puppetlabs/firewall

# define the class, to be applied when this manifest runs
class {'workstation_bootstrap': }
