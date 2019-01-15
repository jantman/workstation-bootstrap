## [3.1.0] Released 2019-01-15

- Update ``bin/run_r10k.sh`` wrapper script for [r10k 3.0.0](https://github.com/puppetlabs/r10k/blob/master/CHANGELOG.mkd#300) compatibility and to force r10k to overwrite locally-changed files.

## [3.0.0] Released 2018-05-21

- Completely rework from previous system-wide installation to be run directly from git clone

## [2.0.0] Released 2018-02-04

- Update all dependencies and layout via modulesync, to modern Puppet5 version.
- Properly rename README file to README.md
- Fix layout now that r10k (> 2.1.0) can handle local modules; move workstation_bootstrap manifrsts into ``puppet/modules``
- Update ``.fixtures.yml`` to pull in proper versions
- Remove unused files from repo
- Update documentation
- Fix unit tests for new layout
- Test against modern Puppet versions (puppet4 and puppet5)
- Fix bug in ``config_version.sh``
- Convert ``puppet/config/hiera.yaml`` from version 3 to version 5
- Fix dependency version issues and unmet dependencies in Puppetfile and .fixtures.yml
- Stop checking coverage; this doesn't work for node/host tests
- Add spec tests for nodes/hosts
- Add ``metadata.json`` to support release process.

## [1.1.0] Released 2017-07-09

- bump saz/sudo requirement per jantman/puppet-archlinux-workstation

## 1.0.0 Released 2017-05-07

- allow disabling global firewall module purge via hiera setting

## 0.0.1 Released 2014-03-15

- initial module creation
- migration of a bunch of stuff from https://github.com/jantman/puppet-archlinux-macbookretina

[3.1.0]: https://github.com/jantman/workstation-bootstrap/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/jantman/workstation-bootstrap/compare/2.0.0...3.0.0
[2.0.0]: https://github.com/jantman/workstation-bootstrap/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/jantman/workstation-bootstrap/compare/1.0.0...1.1.0
