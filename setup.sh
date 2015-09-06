#!/bin/bash

MYSOURCE=$(realpath -s $0)
PUPPETDIR=/etc/puppetlabs/puppet
SETUP_LOC=$PUPPETDIR/workstation-bootstrap/setup.sh
if [[ "$MYSOURCE" != "$SETUP_LOC" ]]; then
    >&2 echo "ERROR: setup script must be located at: $SETUP_LOC"
    exit 1
fi

[[ -e $PUPPETDIR/hiera.yaml ]] && { echo "Removing existing $PUPPETDIR/hiera.yaml"; rm -f $PUPPETDIR/hiera.yaml; }

echo "Symlinking hiera.yaml from git repo"
ln -s $PUPPETDIR/workstation-bootstrap/puppet/config/hiera.yaml $PUPPETDIR/hiera.yaml
