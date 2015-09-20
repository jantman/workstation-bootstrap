require 'yaml'

# figure out some paths
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
spec_path = File.join(proj_root, 'spec', 'fixtures', 'manifests', 'site.pp')
sitepp_path = File.join(proj_root, 'puppet', 'manifests', 'site.pp')
hiera_conf = File.join(proj_root, 'puppet', 'config', 'hiera.yaml')
spec_hiera_conf = File.join(proj_root, 'spec', 'fixtures', 'hiera_spec.yaml')
hiera_dir = File.join(proj_root, 'puppet', 'hiera')

# ensure spec/fixtures/manifests/site.pp is symlinked to puppet/manifests/site.pp
unless File.exists?(spec_path)
  FileUtils.ln_s(sitepp_path, spec_path)
end

# write out our hiera config for spec testing
hieraconf = YAML.load_file(hiera_conf)
hieraconf[:yaml][:datadir] = hiera_dir
File.open(spec_hiera_conf, 'w') { |f| f.write hieraconf.to_yaml }

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.hiera_config = spec_hiera_conf
end
