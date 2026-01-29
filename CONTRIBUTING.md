# Contributing to FightCityTickets

Thank you for your interest in contributing to FightCityTickets! This document outlines the process for contributing to this project.

## Getting Started

### Prerequisites

- macOS with Xcode 15.0+
- XcodeGen 2.38+ (`brew install xcodegen`)
- SwiftLint 0.54+ (`brew install swiftlint`)
- Git

### Setting Up Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/iOS-FightCityTickets.git
   cd iOS-FightCityTickets
   ```

3. Run the bootstrap script to set up the project:
   ```bash
   chmod +x Scripts/bootstrap.sh
   ./Scripts/bootstrap.sh
   ```

4. Generate the Xcode project:
   ```bash
   ./Scripts/generate.sh
   ```

5. Open the project in Xcode:
   ```bash
   open FightCityTickets.xcodeproj
   ```

## Development Workflow

### 1. Create a Branch

Create a new branch for your changes:
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Follow the project's coding standards:
- Use Swift 5.9+
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guelines/)
- Run SwiftLint before committing (`./Scripts/lint.sh`)
- Write tests for new functionality

### 3. Test Your Changes

Run the test suite:
```bash
./Scripts/test.sh
```

### 4. Commit Your Changes

Write a clear commit message:
```
feat: Add OCR confidence scoring feature

- Implemented confidence scorer using Vision framework
- Added unit tests for edge cases
- Updated documentation
```

### 5. Push and Create Pull Request

Push your changes and create a PR on GitHub.

## Code Standards

### SwiftLint Rules

This project uses SwiftLint for code quality. Configuration is in `.swiftlint.yml`.

Before committing, run:
```bash
./Scripts/lint.sh
```

### Architecture

The project follows a three-module architecture:

- **FightCity**: Main iOS application
- **FightCityiOS**: iOS-specific framework (Vision, AVFoundation)
- **FightCityFoundation**: Portable framework (Foundation only)

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

### Testing

- Unit tests go in `Tests/UnitTests/`
- Integration tests go in `Tests/IntegrationTests/`
- UI tests go in `Tests/UITests/`

## Pull Request Process

1. Ensure all tests pass
2. Ensure SwiftLint passes with no warnings
3. Update documentation as needed
4. Request review from maintainers
5. Address feedback and get approval

## Reporting Issues

When reporting issues, include:
- iOS version
- Xcode version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.
