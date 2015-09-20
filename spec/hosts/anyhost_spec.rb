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
      :osfamily => 'Archlinux',
      :kernel   => 'Linux',
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
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }}

    it { should compile.with_all_deps }

    it { should_not contain_class('archlinux_workstation') }

    it { should contain_resources('firewall').with_purge(true) }
    it { should contain_class('firewall') }
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }

  end # context 'on osfamily RedHat'

end # describe 'workstation_bootstrap'
