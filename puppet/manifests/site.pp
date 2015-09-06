# == Class: workstation_bootstrap
#
# Main site.pp entry point for workstation_bootstrap project, mainly to handle
# puppetlabs-firewall and other things that need to be in top-scope context.
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# https://github.com/jantman/workstation-bootstrap/blob/production/manifests/site.pp
#

resources { 'firewall':
  purge => true
}

# TODO - these next 2 lines should be able to come from Hiera
class { ['workstation_bootstrap::firewall_pre', 'workstation_bootstrap::firewall_post']: }
class { 'firewall': }
# END TODO

Firewall {
  before  => Class['workstation_bootstrap::firewall_post'],
  require => Class['workstation_bootstrap::firewall_pre'],
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
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 accept related established rules':
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
