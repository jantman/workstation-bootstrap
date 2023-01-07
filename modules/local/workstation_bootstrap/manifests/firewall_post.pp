# set default puppetlabs-firewall drop rule
class workstation_bootstrap::firewall_post {
  # create a new chain to log and then drop
  firewallchain {'LOGDROP:filter:IPv4':
    ensure => present,
  }
  -> firewall {'1 LOGDROP-log':
    chain      => 'LOGDROP',
    limit      => '2/min',
    jump       => 'LOG',
    log_level  => '4',
    log_uid    => true,
    log_prefix => 'IPTables-LOGDROP: ',
    before => undef,
  }
  -> firewall {'2 LOGDROP-drop':
    chain  => 'LOGDROP',
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

  # now on the default chain, as the final rule, jump to LOGDROP
  firewall { '999 drop all and log':
    jump => 'LOGDROP',
    before => undef,
  }
}
