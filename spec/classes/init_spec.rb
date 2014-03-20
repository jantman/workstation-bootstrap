require 'spec_helper'

describe 'workstation_bootstrap' do
  context 'supported operating systems' do
    describe "archlinux_workstation class without any parameters on Archlinux" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'Archlinux',
      }}

      let(:precondition) { 'define archlinux_workstation {}' }

      it { should compile.with_all_deps }

      it { should contain_class('archlinux_workstation') }
    end # describe "foo"

  end # context 'supported operating systems'

end # describe 'workstation_bootstrap'
