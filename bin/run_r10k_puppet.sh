#!/bin/bash

set -x
/etc/puppetlabs/code/workstation-bootstrap/bin/run_r10k.sh && /etc/puppetlabs/code/workstation-bootstrap/bin/run_puppet.sh $@
