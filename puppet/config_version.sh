#!/bin/bash
#
# script to get the pwd git commit hash
# this is largely from: https://github.com/raphink/puppet-puppet/blob/a32727935a953fb984169bc21c905c7e1aef5cda/files/config_version_git.sh
#

echo -n $(/usr/bin/git rev-parse HEAD)

/usr/bin/git diff-files --quiet --ignore-submodules --
[[ $? == 0 ]] || echo -n " [+]"

echo
