# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Run the sync script automatically on Renovate vendir branches and push the result for review.
- Add a check which fails a pull request if the sync script was not run.

### Fixed

- Set the CRD subchart version from the upstream version in `vendir.yml` when the CRDs change.

## [0.2.0] - 2026-07-14

### Changed

- Improve Renovate config.
- chore: update vendir https://github.com/k8snetworkplumbingwg/whereabouts to v0.9.4

## [0.1.0] - 2026-03-03

### Added

- Add upstream chart at v0.9.3

[Unreleased]: https://github.com/giantswarm/whereabouts/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/giantswarm/whereabouts/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/giantswarm/whereabouts/releases/tag/v0.1.0
