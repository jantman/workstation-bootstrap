# workstation-bootstrap 2_hiera_classes.pp
#
# This manifest includes classes defined in hiera.
#
# See README.markdown for usage and further information.
#
# The canonical source of the latest unmodified version of this file is:
# <https://github.com/jantman/workstation-bootstrap/blob/production/puppet/manifests/2_hiera_classes.pp>
#

# include classes from Hiera
hiera_include('classes')
