# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2021-10-24
### Added
- add OpenFortiVPN in Fedora
- add Balena Etcher package repository and install in Fedora

### Changed
- fix Rocky Server script
  - rustup
  - cockpit

### Deprecated
- Raspberry Pi OS Server
- Debian Desktop

## [0.1.1] - 2021-10-23
### Added
- add vlc for workstation/desktop
- add git-extras
- use RPM Fusion for Fedora
- Fedora Workstation scripts
- add rsync in Server scripts
- Debian Family Desktop srcipts
- add tmux bashcompletion
- add timetrap in Desktop scripts 
- add rbenv in Desktop scripts
- add htop in the list of additional software to install
- add ncdu in the list of additional software to install
- add EPEL repo to Rocky linux post-install

### Fixed
- tests to avoid double installation
 
### Changed
- disable cockpit in desktop post-install

## 0.1.0 - 2021-10-16 [YANKED]
### Added
- Rocky Linux Desktop and Server post-install script
- Raspberry Pi OS post-install script