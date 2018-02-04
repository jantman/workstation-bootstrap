require 'puppet'

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

# helper to allow easy definition of a base set of facts for all specs
def spec_facts(additional = {})
  facts = {
    :osfamily        => 'Archlinux',
    :operatingsystem => 'Archlinux',
    :concat_basedir  => '/tmp',
    :processorcount  => 8,
    :puppetversion   => Puppet::PUPPETVERSION,
    :virtual         => 'physical',
    :interfaces      => 'eth0,eth1,lo',
    # structured facts
    :os              => { 'family' => 'Archlinux' },
    :processors      => { 'count' => 8 },
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
    }
  }
  facts.merge(additional)
end

RSpec.configure do |c|
  c.module_path = File.join(proj_root, 'puppet', 'modules', 'workstation_bootstrap')
end
