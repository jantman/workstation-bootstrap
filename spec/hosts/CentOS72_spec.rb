require 'spec_helper'

context 'hosts' do
  describe 'CentOS72' do
    let(:environment) { 'production' }
    let(:facts) { facts_for_host('CentOS') }

    it { should compile.with_all_deps }

    # defauls.yaml
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }
    it { should contain_class('firewall') }

    # osfamily Archlinux
    it { should_not contain_class('archlinux_workstation') }

    # osfamily_productname
    it { should_not contain_class('archlinux_macbookretina') }

    # user_config.yaml
    it { should_not contain_resources('firewall').with_purge(true) }
    it { should contain_class('privatepuppet') }
  end
end
