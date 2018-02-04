require 'spec_helper'

context 'hosts' do
  describe 'ArchLinuxMBP11,4' do
    let(:environment) { 'production' }
    let(:facts) { facts_for_host('Archlinux', 'MacBookPro11,4') }

    it { should compile.with_all_deps }

    # defauls.yaml
    it { should contain_class('workstation_bootstrap::firewall_pre') }
    it { should contain_class('workstation_bootstrap::firewall_post') }
    it { should contain_class('firewall') }

    # osfamily Archlinux
    it { should contain_class('archlinux_workstation').with(
        'username' => 'jantman',
        'makepkg_packager' => 'Jason Antman <jason@jasonantman.com>',
      )
    }
    it { should contain_class('archlinux_workstation::all') }
    it { should contain_class('archlinux_workstation::ssh').with(
        'extra_options' => { 'PubkeyAcceptedKeyTypes' => '+ssh-dss' },
        'allow_users'   => ['jantman']
      )
    }
    it { should contain_class('archlinux_workstation::cronie').with(
        'mail_command' => '/usr/local/bin/gmailer.py'
      )
    }
    it { should contain_class('archlinux_workstation::makepkg').with(
        'make_flags' => '-j6'
      )
    }

    # osfamily_productname
    it { should contain_class('archlinux_macbookretina') }

    # user_config.yaml
    it { should_not contain_resources('firewall').with_purge(true) }
    it { should contain_class('privatepuppet') }
  end
end
