require 'spec_helper'

describe 'anyhost' do
  context 'on all osfamilies' do
    let(:facts) {{
      :kernel   => 'Linux',
    }}

    it { should compile.with_all_deps }

    it { should contain_resources('firewall').with_purge(true) }
    it { should contain_class('firewall') }
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }

  end # context 'on all osfamilies'

  context 'on osfamily Archlinux' do
    let(:params) {{ }}
    let(:facts) {{
                   :kernel          => 'Linux',
                   :concat_basedir  => '/tmp',
                   :osfamily        => 'Archlinux',
                   :operatingsystem => 'Archlinux',
                   :os              => { 'family' => 'Archlinux', 'name' => 'Archlinux' },
                   :productname     => 'MacBookPro11,4',
                   :dmi             => { 'product' => { 'name' => 'MacBookPro11,4' } },
                   :interfaces      => 'enp4s0,lo',
                   :networking      => {
                     'interfaces' => {
                       'enp4s0' => {
                         'dhcp' => "192.168.0.1",
                       },
                       'lo' => {
                         'ip' => "127.0.0.1",
                       }
                     },
                   }
    }}

    it { should compile.with_all_deps }

    it { should contain_class('archlinux_workstation') }

    it { should contain_resources('firewall').with_purge(true) }
    it { should contain_class('firewall') }
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }

  end # context 'on osfamily Archlinux'

  context 'on osfamily RedHat' do
    let(:params) {{ }}
    let(:facts) {{
                   :kernel      => 'Linux',
                   :osfamily    => 'RedHat',
                   :os          => { 'family' => 'RedHat' },
                   :productname => 'MacBookPro11,4',
                   :dmi         => { 'product' => { 'name' => 'MacBookPro11,4' } },
    }}

    it { should compile.with_all_deps }

    it { should_not contain_class('archlinux_workstation') }

    it { should contain_resources('firewall').with_purge(true) }
    it { should contain_class('firewall') }
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }

  end # context 'on osfamily RedHat'

end # describe 'workstation_bootstrap'
