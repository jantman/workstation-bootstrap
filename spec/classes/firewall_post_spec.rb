require 'spec_helper'

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
