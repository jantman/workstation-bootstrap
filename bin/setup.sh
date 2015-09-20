#!/bin/bash

MYSOURCE="$(cd "$(dirname "$0")" && pwd)"
PUPPETDIR=/etc/puppetlabs/code
SETUP_LOC=$PUPPETDIR/workstation-bootstrap/bin
if [[ "$MYSOURCE" != "$SETUP_LOC" ]]; then
    >&2 echo "ERROR: setup script must be located at: $SETUP_LOC (not $MYSOURCE)"
    exit 1
fi

[[ -e $PUPPETDIR/hiera.yaml ]] && { echo "Removing existing $PUPPETDIR/hiera.yaml"; rm -f $PUPPETDIR/hiera.yaml; }

echo "Symlinking $PUPPETDIR/hiera.yaml to $PUPPETDIR/workstation-bootstrap/puppet/config/hiera.yaml"
ln -s $PUPPETDIR/workstation-bootstrap/puppet/config/hiera.yaml $PUPPETDIR/hiera.yaml

mkdir -p $PUPPETDIR/environments

echo "Symlinking $PUPPETDIR/environments/production to $PUPPETDIR/workstation-bootstrap/puppet"
ln -s $PUPPETDIR/workstation-bootstrap/puppet $PUPPETDIR/environments/production
