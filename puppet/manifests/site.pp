# workstation-bootstrap site.pp
#
# This manifest sets up the requirements for the puppetlabs-firewall module,
# includes classes defined in Hiera, and anything else that _must_ be done
# in top-scope. It also adds a default firewall rule to allow SSH.
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# <https://github.com/jantman/workstation-bootstrap/blob/production/puppet/manifests/0_site.pp>
#

resources { 'firewall':
  purge => true
}

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
  }->
  firewall { '004 accept SSH':
    dport    => 22,
    proto    => 'tcp',
    action   => 'accept',
  }
}

class workstation_bootstrap::firewall_post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}

# Include classes from Hiera, unless in ``exclude_classes``
# see: <https://tickets.puppetlabs.com/browse/HI-467?focusedCommentId=213339&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-213339>
$hiera_classes = lookup('classes', Array, 'unique')
notice("hiera 'classes': ${hiera_classes}")

$hiera_remove_classes = lookup('remove_classes', Array, 'unique')
notice("hiera 'remove_classes': ${hiera_remove_classes}")

$final_classes = $hiera_classes - $hiera_remove_classes
notice("final hiera 'classes': ${final_classes}")

include($final_classes)
