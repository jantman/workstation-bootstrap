proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
spec_path = File.join(proj_root, 'spec', 'fixtures', 'manifests', 'site.pp')
sitepp_path = File.join(proj_root, 'puppet', 'manifests', 'site.pp')
unless File.exists?(spec_path)
  FileUtils.ln_s(sitepp_path, spec_path)
end

require 'puppetlabs_spec_helper/module_spec_helper'
