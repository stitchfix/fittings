# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Switched to using `Hashie::Mash` for YAML parsing. This provides behavior that is more consistent, while remaining similar. It did not cause any tests to fail, but may be a breaking change depending on how you are using the gem.
