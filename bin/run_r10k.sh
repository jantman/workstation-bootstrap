#!/bin/bash

CLONEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
set -x
cd $CLONEDIR
git fetch && git pull
/usr/bin/r10k puppetfile install \
  -v \
  --moduledir=${CLONEDIR}/modules/r10k \
  --puppetfile=${CLONEDIR}/Puppetfile \
  --force \
  $@
