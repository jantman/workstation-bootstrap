require 'puppet'

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  hieraconf = File.read(File.join(proj_root, 'puppet', 'config', 'hiera.yaml'))
  hieraconf.sub!('/etc/puppetlabs/code/workstation-bootstrap/puppet/hiera', File.join(proj_root, 'puppet', 'hiera'))
  File.open(File.join(proj_root, 'spec', 'fixtures', 'hiera.yaml'), 'w') { |f| f.write(hieraconf) }
  c.hiera_config = File.join(proj_root, 'spec', 'fixtures', 'hiera.yaml')
  c.manifest = File.join(proj_root, 'puppet', 'manifests', 'site.pp')
end
