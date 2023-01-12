# Changelog for PSQueue

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Added back license URI i module manifest as the bug causing PowershellGet to fail packageing the module in beta17 is resolved.

## [1.4.3] - 2022-11-14

### Changed

- Implemented new CI/CD pipeline

## [1.4.2] - 2021-12-13

### changed

- Updated build process pipeline

## [1.4.1] - 2021-04-03

### fixed

- Updated function scripts with new psscriptinfo format

## [1.4.0] - 2021-04-01

### removed

- Removed signature from all scriptfiles due to certificate validation issue

## [1.2.0] - 2021-03-23

### changed

- Updated module manifest privatedata

## [1.0.5] - 2021-01-22

### changed

- Built for PSGallery publish

## [1.0.4] - 2021-01-22

### added

- Add-QueueItem: Added support for items to be passed via pipeline
- Function help added

## [1.0.0] - 2021-01-14

### added

- First version
