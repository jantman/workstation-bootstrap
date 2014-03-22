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
#mod 'saz/ssh', '2.3.3' # dependency of archlinux_workstation
mod 'ssh', # my fork of saz/ssh
  :git => 'https://github.com/jantman/puppet-ssh.git',
  :ref => 'archlinux'
mod 'puppetlabs/firewall', '1.0.2'
mod 'puppetlabs/inifile', '1.0.3'

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
