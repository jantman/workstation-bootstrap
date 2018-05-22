require 'puppet'

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  hieraconf = File.read(File.join(proj_root, 'hiera.yaml.template'))
  hieraconf.sub!('%%CLONEDIR%%', proj_root)
  File.open(File.join(proj_root, 'spec', 'fixtures', 'hiera.yaml'), 'w') { |f| f.write(hieraconf) }
  c.hiera_config = File.join(proj_root, 'spec', 'fixtures', 'hiera.yaml')
  c.manifest = File.join(proj_root, 'manifests', 'site.pp')
end

def facts_for_host(ostype, product = 'Unknown')
  facts = {
    :kernel          => 'Linux',
    :puppetversion   => Puppet::PUPPETVERSION,
    :virtual         => 'physical',
    :productname     => product,
    :interfaces      => 'eth0,eth1,lo',
    # structured facts
    :dmi             => { 'product' => { 'name' => product } },
    :processors      => { 'count' => 6 },
    :disks           => {
      'sda' => {
        'model' => "APPLE SSD SM0256",
        'size' => "233.76 GiB",
        'size_bytes' => 251000193024,
        'vendor' => "ATA"
      },
      'sdb' => {
        'model' => "SD Card Reader",
        'size' => "0 bytes",
        'size_bytes' => 0,
        'vendor' => "APPLE"
      }
    },
    :networking      => {
      'interfaces' => {
        'eth0' => {
          'dhcp' => "192.168.0.1",
          'ip' => "192.168.0.24",
        },
        'eth1' => {
          'dhcp' => "192.168.0.1",
          'ip' => "192.168.0.24",
        },
        'lo' => {
          'ip' => "127.0.0.1",
          'ip6' => "::1",
        },
      },
    },
    :selinux                => 'false',
  }
  if ostype == 'CentOS'
    facts[:osfamily]               = 'RedHat'
    facts[:operatingsystem]        = 'CentOS'
    facts[:operatingsystemrelease] = '7.2'
    facts[:os]                     = { 'family' => 'RedHat', 'name' => 'CentOS' }
  elsif ostype == 'Archlinux'
    facts[:osfamily]               = 'Archlinux'
    facts[:operatingsystem]        = 'Archlinux'
    facts[:os]                     = { 'family' => 'Archlinux', 'name' => 'Archlinux' }
  else
    raise RuntimeError, "Unsupported ostype: #{ostype}"
  end
  facts
end
