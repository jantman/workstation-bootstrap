# This is currently a noop but will be supported in the future.
forge 'forge.puppetlabs.com'

#
# Until https://github.com/adrienthebo/r10k/issues/38 is fixed,
# r10k doesn't have dependency resolution so we need to specify
# everything here explicitly.
#

#################
# forge modules #
#################

mod 'puppetlabs/stdlib', '4.1.0'
mod 'saz/sudo', '3.0.3' # dependency of archlinux_workstation
mod 'saz/ssh', '2.3.6' # dependency of archlinux_workstation
mod 'puppetlabs/firewall', '1.0.2'
mod 'puppetlabs/inifile', '1.0.3'
mod 'puppetlabs/vcsrepo', '0.2.0'
mod 'eirc/single_user_rvm', '0.3.0'
mod 'nanliu/staging', '0.4.0'

##################
# github modules #
##################

mod 'archlinux_workstation',
  :git => 'https://github.com/jantman/puppet-archlinux-workstation.git'

####################
# personal modules #
####################

mod 'privatepuppet',
  :git => 'git@github.com:jantman/privatepuppet.git'
