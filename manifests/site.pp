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


  #################################################
  # personal config - probably only useful to me, #
  #  or relatively custom                         #
  #################################################

  # my private stuff
  class {'privatepuppet': }
}

# define the class, to be applied when this manifest runs
class {'workstation_bootstrap': }
