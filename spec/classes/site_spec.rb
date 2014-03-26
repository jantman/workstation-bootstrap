require 'spec_helper'

describe 'workstation_bootstrap' do

  let(:pre_condition) { 'class archlinux_workstation ($username, ) {}' }
  let(:pre_condition) { 'class privatepuppet {}' }

  context 'on all osfamilies' do
    let(:facts) {{
      :kernel   => 'Linux',
    }}

    describe 'should compile with all deps' do
      it { should compile.with_all_deps }
    end

    it { should contain_class('privatepuppet') }

    it { should contain_class('workstation_bootstrap') }

    it { should contain_single_user_rvm__install() }

    it { should contain_single_user_rvm__install_ruby(['ruby-1.8.7', 'ruby-1.9.3', 'ruby-2.0.0']) }

  end # context 'on all osfamilies'

  context 'on osfamily Archlinux' do
    let(:params) {{ }}
    let(:facts) {{
      :osfamily => 'Archlinux',
      :kernel   => 'Linux',
    }}

    describe 'should compile with all deps' do
      it { should compile.with_all_deps }
    end

    it { should contain_class('archlinux_workstation') }

  end # context 'on osfamily Archlinux'

  context 'on osfamily RedHat' do
    let(:params) {{ }}
    let(:facts) {{
      :osfamily => 'RedHat',
      :kernel   => 'Linux',
    }}

    describe 'should compile with all deps' do
      it { should compile.with_all_deps }
    end

    it { should_not contain_class('archlinux_workstation') }

  end # context 'on osfamily RedHat'

  context 'puppetlabs/firewall' do
    let(:facts) {{
      :osfamily => 'Archlinux',
      :kernel   => 'Linux',
    }}

    describe 'should compile with all deps' do
      it { should compile.with_all_deps }
    end

    it { should contain_class('firewall') }
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }

  end # context 'puppetlabs/firewall'

end # describe 'workstation_bootstrap'

describe 'workstation_bootstrap::firewall_pre' do
  let(:pre_condition) { 'class archlinux_workstation ($username, ) {}' }
  let(:pre_condition) { 'class privatepuppet {}' }

  let(:facts) {{
    :osfamily => 'RedHat',
    :kernel   => 'Linux',
  }}

  it { should compile.with_all_deps }

  it { should contain_firewall('000 accept all icmp').with({
    'proto'   => 'icmp',
    'action'  => 'accept',
    'require' => nil,
    }).that_comes_before('Firewall[001 accept all to lo interface]')
  }

  it { should contain_firewall('001 accept all to lo interface').with({
    'proto'   => 'all',
    'iniface' => 'lo',
    'action'  => 'accept',
    'require' => nil,
    }).that_comes_before('Firewall[002 accept related established rules]')
  }

  it { should contain_firewall('002 accept related established rules').with({
    'proto'   => 'all',
    'ctstate' => ['RELATED', 'ESTABLISHED'],
    'action'  => 'accept',
    'require' => nil,
    })
  }
end # describe 'workstation_bootstrap::firewall_pre'

describe 'workstation_bootstrap::firewall_post' do
  let(:pre_condition) { 'class archlinux_workstation ($username, ) {}' }
  let(:pre_condition) { 'class privatepuppet {}' }

  let(:facts) {{
    :osfamily => 'RedHat',
    :kernel   => 'Linux',
  }}

  it { should compile.with_all_deps }

  it { should contain_firewall('999 drop all').with({
    'proto'   => 'all',
    'action'  => 'drop',
    'before'  => nil,
    })
  }
end # describe 'workstation_bootstrap::firewall_post'
