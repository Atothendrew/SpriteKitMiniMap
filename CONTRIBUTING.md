# Contributing to MiniMapPackage

Thank you for your interest in contributing to MiniMapPackage! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Xcode 15.0+
- Swift 5.9+
- Git

### Setting Up the Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/MiniMapPackage.git
   cd MiniMapPackage
   ```
3. Open the package in Xcode:
   ```bash
   xed Package.swift
   ```

## Development Workflow

### Running Tests

```bash
swift test
```

### Running the Example

```bash
cd Examples/MiniMapExampleApp
swift run
```

### Building the Package

```bash
swift build
```

## Code Style Guidelines

### Swift Style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use 2-space indentation
- Prefer `let` over `var` when possible
- Use meaningful variable and function names
- Add documentation comments for public APIs

### File Organization

- Keep related functionality together
- Use clear, descriptive file names
- Group public APIs at the top of files
- Separate concerns into different files when appropriate

### Documentation

- Document all public APIs with Swift documentation comments
- Include usage examples in documentation
- Keep README.md up to date with new features
- Update CHANGELOG.md for all changes

## Making Changes

### Feature Development

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the code style guidelines

3. Add tests for new functionality:
   ```bash
   swift test
   ```

4. Update documentation as needed

5. Commit your changes with a clear message:
   ```bash
   git commit -m "Add feature: brief description"
   ```

6. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

7. Create a Pull Request

### Bug Fixes

1. Create a bug fix branch:
   ```bash
   git checkout -b fix/bug-description
   ```

2. Fix the bug and add a test to prevent regression

3. Update documentation if the fix changes public API

4. Commit and push as above

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows the style guidelines
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Example app still works (if applicable)

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Example app works
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] CHANGELOG updated
```

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Step-by-step instructions
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: OS version, Xcode version, Swift version
- **Code Example**: Minimal code to reproduce the issue

### Feature Requests

When requesting features, please include:

- **Description**: Clear description of the feature
- **Use Case**: Why this feature is needed
- **Proposed API**: How you envision the API working
- **Alternatives**: Any alternative approaches considered

## Release Process

### Version Bumping

- Follow [Semantic Versioning](https://semver.org/)
- Update version in Package.swift
- Update CHANGELOG.md
- Create a release tag

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is complete
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped in Package.swift
- [ ] Release notes are written
- [ ] Tag is created and pushed

## Questions?

If you have questions about contributing, please:

1. Check existing issues and pull requests
2. Search the documentation
3. Open an issue with your question

Thank you for contributing to MiniMapPackage! 