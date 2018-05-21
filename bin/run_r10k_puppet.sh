#!/bin/bash

CLONEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
set -x
cd $CLONEDIR
./bin/run_r10k.sh && ./bin/run_puppet.sh $@
