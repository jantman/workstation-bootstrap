#!/bin/bash

set -x
/etc/puppetlabs/code/workstation_bootstrap/bin/run_r10k.sh && /etc/puppetlabs/code/workstation_bootstrap/bin/run_puppet.sh $@
