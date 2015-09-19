# set default puppetlabs-firewall drop rule
class workstation_bootstrap::firewall_post {
  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
