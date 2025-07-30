# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v1.0.3] - 2025-07-30

### Added
- Automated release from CI/CD pipeline



## [1.0.2] - 2025-07-30

### Improved
- Enhanced macOS cursor handling for better user interaction during drag and resize operations
- More responsive cursor feedback during mini-map interactions

## [1.0.1] - 2025-07-30

### Fixed
- CI build issues with package name resolution
- Removed Linux build (SpriteKit not available on Linux)
- Simplified macOS cursor handling for broader compatibility
- Fixed example app build in CI environment

### Improved
- Enhanced mouse event handling with convenience methods
- Improved drag and resize interaction logic
- Better coordinate system handling
- More robust click vs drag detection
- Persistent dragging state management
- Entity scaling on map resize

### Technical
- Added 19 comprehensive tests for interaction logic
- Improved documentation with integration guide
- Enhanced error handling and edge cases
- Better platform-specific behavior handling

## [1.0.0] - 2025-07-30

### Added
- Core MiniMap class with SpriteKit integration
- MiniMapEntity protocol for type-safe entity definition
- AnyMiniMapEntity type erasure for multiple entity types
- MiniMapLocation enum with 9 predefined positions
- MiniMapSize enum with 4 predefined sizes
- MiniMapDelegate protocol for click handling
- Camera view frame support
- Cross-platform compatibility (iOS, macOS, tvOS, watchOS)
- Comprehensive unit tests
- Example app demonstrating all features

### Features
- Support for multiple entity types simultaneously
- Customizable marker appearance per entity type
- Predefined window locations and sizes
- Click-to-position camera movement
- Real-time entity position updates
- Background and border customization
- Z-position management for proper layering

### Technical
- Pure Swift implementation
- Zero external dependencies (only SpriteKit)
- Type-safe API design
- Memory-efficient type erasure
- Cross-platform color handling with PlatformColor 