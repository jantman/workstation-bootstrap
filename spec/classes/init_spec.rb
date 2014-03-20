require 'spec_helper'

describe 'workstation_bootstrap' do

  let(:pre_condition) { 'class archlinux_workstation ($username, ) {}' }
  let(:pre_condition) { 'class privatepuppet {}' }

  context 'on osfamily Archlinux' do
    let(:params) {{ }}
    let(:facts) {{
      :osfamily => 'Archlinux',
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
    }}

    describe 'should compile with all deps' do
      it { should compile.with_all_deps }
    end

    it { should_not contain_class('archlinux_workstation') }

  end # context 'on osfamily RedHat'

end # describe 'workstation_bootstrap'
