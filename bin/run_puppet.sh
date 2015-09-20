#!/bin/bash

set -x

puppet apply --verbose $@ /etc/puppetlabs/code/environments/production/manifests/site.pp
