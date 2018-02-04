require 'spec_helper'

describe 'workstation_bootstrap' do
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
