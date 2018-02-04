require 'spec_helper'

context 'hosts' do
  describe 'CentOS72' do
    let(:environment) { 'production' }
    let(:facts) {{
      :osfamily               => 'RedHat',
      :kernel                 => 'Linux',
      :productname            => 'Unknown',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '7.2',
      :selinux                => 'false',
    }}

    it { should compile.with_all_deps }

  end # describe 'workstation_bootstrap'
end
