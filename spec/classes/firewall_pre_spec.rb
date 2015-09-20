require 'spec_helper'

describe 'workstation_bootstrap::firewall_pre' do
  let(:facts) {{
    :osfamily => 'RedHat',
    :kernel   => 'Linux',
  }}

  it { should compile.with_all_deps }

  it { should contain_firewall('000 accept all icmp')
               .with({
                       'proto'   => 'icmp',
                       'action'  => 'accept',
                       'require' => nil,
                     })
               .that_comes_before('Firewall[001 accept all to lo interface]')
  }

  it { should contain_firewall('001 accept all to lo interface')
               .with({
                       'proto'   => 'all',
                       'iniface' => 'lo',
                       'action'  => 'accept',
                       'require' => nil,
                     })
               .that_comes_before('Firewall[002 reject local traffic not on loopback interface]')
  }

  it { should contain_firewall('002 reject local traffic not on loopback interface')
               .with({
                       'iniface'     => '! lo',
                       'proto'       => 'all',
                       'destination' => '127.0.0.1/8',
                       'action'      => 'reject',
                       'require'     => nil,
                     })
               .that_comes_before('Firewall[003 accept related established rules]')
  }

  it { should contain_firewall('003 accept related established rules')
               .with({
                       'proto'   => 'all',
                       'ctstate' => ['RELATED', 'ESTABLISHED'],
                       'action'  => 'accept',
                       'require' => nil,
                     })
               .that_comes_before('Firewall[004 accept SSH]')
  }

  it { should contain_firewall('004 accept SSH')
               .with({
                       'dport'   => 22,
                       'proto'   => 'tcp',
                       'action'  => 'accept',
                       'require' => nil,
                     })
  }
end # describe 'workstation_bootstrap::firewall_pre'
