# workstation-bootstrap site.pp
#
# This manifest sets up the requirements for the puppetlabs-firewall module,
# includes classes defined in Hiera, and anything else that _must_ be done
# in top-scope. It also adds a default firewall rule to allow SSH.
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# <https://github.com/jantman/workstation-bootstrap/blob/master/puppet/manifests/site.pp>
#

if (lookup('firewall_purge', Boolean, 'first', true) == true) {
  notice("hiera 'firewall_purge' is true, or default; purging all unmanaged iptables rules")
  resources { 'firewall':
    purge => true
  }
} else {
  notice("hiera 'firewall_purge' is *false*, not purging any unmanaged iptables rules globally")
}

Firewall {
  before  => Class['workstation_bootstrap::firewall_post'],
  require => Class['workstation_bootstrap::firewall_pre'],
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
