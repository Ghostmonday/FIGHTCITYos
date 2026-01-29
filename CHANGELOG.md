# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Repository reorganization into three-module architecture (FightCity, FightCityiOS, FightCityFoundation)
- 100% Swift native codebase (no C code)
- Comprehensive test structure with unit, integration, and UI tests
- CI/CD workflows for iOS and Linux
- Development scripts for bootstrap, generate, lint, test, and release
- Privacy manifest (PrivacyInfo.xcprivacy) for iOS 17+ compliance
- SwiftLint configuration for code quality

### Changed
- Project restructured from monolithic to modular architecture
- All iOS-specific code moved to FightCityiOS framework
- Pure Foundation code moved to FightCityFoundation framework

### Removed
- C port files (fct_*.h, fct_*.c)
- Redundant Swift Package Manager setup (Packages/FightCityTicketsCore/)
- Old directory structure (App/, Core/, Domain/, Network/, UI/)

## [1.0.0] - 2024-01-28

### Added
- Initial iOS app structure
- Camera capture functionality using AVFoundation
- OCR text recognition using Vision framework
- Citation validation and processing
- Telemetry service for analytics
- Basic UI screens (Capture, Confirmation, History, Onboarding)
- XcodeGen project configuration

### Features
- Camera preview and capture
- OCR processing for ticket recognition
- Citation data model
- Network API client
- Offline queue for telemetry

### Technology Stack
- Swift 5.9
- iOS 16.0+
- SwiftUI + UIKit
- Vision Framework
- AVFoundation
