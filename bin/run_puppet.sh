#!/bin/bash

CLONEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
set -x
cd $CLONEDIR

puppet apply --verbose $@ \
  --hiera_config=${CLONEDIR}/hiera.yaml
  --modulepath="${CLONEDIR}/modules/local:${CLONEDIR}/modules/r10k"
  ${CLONEDIR}/manifests/site.pp
