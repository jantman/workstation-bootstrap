require 'spec_helper'

describe 'workstation_bootstrap' do
  context 'supported operating systems' do
    ['Archlinux'].each do |osfamily|
      describe "archlinux_workstation class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('archlinux_workstation') }
      end
    end

  end

end
