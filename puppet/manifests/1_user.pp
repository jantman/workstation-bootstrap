# workstation-bootstrap 1_user.pp
#
# This manifest is the place for users to define their own specific
# code, if it needs to be evaluated in top-scope (i.e. outside of Hiera).
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# <https://github.com/jantman/workstation-bootstrap/blob/production/puppet/manifests/1_user.pp>
#

# Arch-specific stuff
if $::osfamily == 'Archlinux' {

  #include 'archlinux_workstation'
  notify {'archlinux-specific': }

  # Arch laptop specific
  #if $::type == 'Notebook' or $::type == 'Portable' or $::type == 'LapTop' or $::type == 'Sub Notebook' {
  #  # nothing yet...
  #}

  # MacBookPro Retina 10,1-specific
  #if $::bios_version =~ /^MBP101.+/ or $::productname == 'MacBookPro10,1' {
  #  # TODO: https://github.com/jantman/puppet-archlinux-macbookretina
    #}
  see https://tickets.puppetlabs.com/browse/HI-467
}
