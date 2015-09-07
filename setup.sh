#!/bin/bash

MYSOURCE=$(realpath -s $0)
PUPPETDIR=/etc/puppetlabs/code
SETUP_LOC=$PUPPETDIR/workstation-bootstrap/setup.sh
if [[ "$MYSOURCE" != "$SETUP_LOC" ]]; then
    >&2 echo "ERROR: setup script must be located at: $SETUP_LOC"
    exit 1
fi

[[ -e $PUPPETDIR/hiera.yaml ]] && { echo "Removing existing $PUPPETDIR/hiera.yaml"; rm -f $PUPPETDIR/hiera.yaml; }

echo "Symlinking $PUPPETDIR/hiera.yaml to $PUPPETDIR/workstation-bootstrap/puppet/config/hiera.yaml"
ln -s $PUPPETDIR/workstation-bootstrap/puppet/config/hiera.yaml $PUPPETDIR/hiera.yaml

mkdir -p $PUPPETDIR/environments/production

echo "Symlinking $PUPPETDIR/environments/production/manifests to $PUPPETDIR/workstation-bootstrap/puppet/manifests"
ln -s $PUPPETDIR/workstation-bootstrap/puppet/manifests $PUPPETDIR/environments/production/manifests

echo "Symlinking $PUPPETDIR/environments/production/modules to $PUPPETDIR/workstation-bootstrap/puppet/modules"
ln -s $PUPPETDIR/workstation-bootstrap/puppet/modules $PUPPETDIR/environments/production/modules
