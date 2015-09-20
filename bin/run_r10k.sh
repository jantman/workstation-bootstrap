#!/bin/bash

set -x

PUPPETFILE=/etc/puppetlabs/code/workstation-bootstrap/puppet/Puppetfile PUPPETFILE_DIR=/etc/puppetlabs/code/workstation-bootstrap/puppet/modules /usr/bin/r10k puppetfile install $@
