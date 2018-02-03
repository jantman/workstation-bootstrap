#!/bin/bash

set -x
pushd /etc/puppetlabs/code/workstation-bootstrap/puppet/
git fetch && git pull
popd
PUPPETFILE=/etc/puppetlabs/code/workstation-bootstrap/puppet/Puppetfile PUPPETFILE_DIR=/etc/puppetlabs/code/workstation-bootstrap/puppet/modules /usr/bin/r10k puppetfile install $@
