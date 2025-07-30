# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release preparation
- Comprehensive documentation
- Example app with interactive position cycling

## [1.0.0] - 2025-01-21

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