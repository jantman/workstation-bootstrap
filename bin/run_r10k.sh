#!/bin/bash

CLONEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
set -x
cd $CLONEDIR
git fetch && git pull
PUPPETFILE=${CLONEDIR}/Puppetfile \
  PUPPETFILE_DIR=${CLONEDIR}/modules/r10k \
  /usr/bin/r10k puppetfile install -v $@
