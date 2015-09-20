#!/bin/bash

if [ -z "$1" ]; then
    >&2 echo "USAGE: hiera_show_value.sh KEY_NAME"
    exit 1
fi

# Note the "Note" box in the Hiera docs on command line usage with YAML scopes
# <http://docs.puppetlabs.com/hiera/3.0/command_line.html#json-and-yaml-scopes>
#
#    For Puppet, facts are top-scope variables, so their fully-qualified form is
#    $::fact_name. When called from within Puppet, Hiera will correctly interpolate
#    %{::fact_name}. However, Facter’s command-line output doesn’t follow this
#    convention — top-level facts are simply called fact_name. That means you’ll
#    run into trouble in this section if you have %{::fact_name} in your hierarchy.
#
# As a result, we need to munge Facter's YAML output to match what Hiera/Puppet
# expect.
facter --yaml | ruby -e 'require "yaml"; orig = YAML.load(STDIN.read); final = Hash[orig.map {|k, v| ["::#{k}", v] }]; puts YAML.dump(final)' > /tmp/facts.yaml
if [[ "$1" == "classes" ]]; then
    # -a -> array
    hiera -d -y /tmp/facts.yaml -a $1
else
    hiera -d -y /tmp/facts.yaml $1
fi
