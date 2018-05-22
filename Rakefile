require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'puppet-strings' if Bundler.rubygems.find_name('puppet-strings').any?
require 'vandamme' if Bundler.rubygems.find_name('vandamme').any?
require 'octokit' if Bundler.rubygems.find_name('octokit').any?
require 'json'
require 'fileutils'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.pattern = 'modules/local/**/*.pp'

desc "NON-PARALLEL version of release_checks"
task :release_checks_nonparallel do
  FileUtils.rm_rf('modules/r10k') if Dir.exist?('modules/r10k')
  Rake::Task[:lint].invoke
  Rake::Task[:validate].invoke
  Rake::Task[:spec].invoke
  Rake::Task["check:symlinks"].invoke
  Rake::Task["check:test_file"].invoke
  Rake::Task["check:dot_underscore"].invoke
  Rake::Task["check:git_ignore"].invoke
end

if Bundler.rubygems.find_name('puppet-blacksmith').any? && Bundler.rubygems.find_name('vandamme').any?
  bsmith = Blacksmith::RakeTask.new do |t|
    t.tag_message_pattern = "Version %s" # Signed tags must have a message
    t.tag_sign = true # enable GPG signing
  end

  desc 'Tag git (signed), push tag, interactively verify changelog, create GitHub Release'
  task :github_release do
    fail('ERROR: you must export GITHUB_TOKEN env var') unless ENV.include?('GITHUB_TOKEN')
    client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    # ensure we have valid auth
    client.user
    # get the module version
    mod = Blacksmith::Modulefile.new
    modver = mod.version
    modtag = "v#{modver}"
    # make sure we don't already have a release for it
    client.releases('jantman/workstation-bootstrap').each do |r|
      abort("ERROR: GitHub Release already exists for tag #{modtag}") if modtag == r.tag_name
    end
    puts "Module version: #{modver}"
    chglog = Vandamme::Parser.new(
      changelog: File.read('CHANGELOG.md'),
      version_header_exp: /## \[(\d+\.\d+\.\d+)\] Released (\d{4}-\d{2}-\d{2})/,
      format: 'markdown'
    ).parse
    fail("ERROR: no CHANGELOG.md entry for version #{modver}") unless chglog.has_key?(modver)
    puts "Changelog for #{modver}:\n\n#{chglog[modver]}\n\n"
    print "Does this look correct? [y|N] "
    abort('Aborted! Exiting.') unless STDIN.gets.strip == 'y'
    puts "Tagging..."
    Rake::Task["module:tag"].invoke
    puts "Pushing git with tags..."
    bsmith.git.push!
    puts "Creating GitHub Release..."
    rel = client.create_release(
      'jantman/workstation-bootstrap',
      modtag,
      name: modver,
      body: chglog[modver]
    )
    puts "Created release: #{rel.html_url}"
  end
end
