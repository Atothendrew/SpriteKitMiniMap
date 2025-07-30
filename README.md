# MiniMapPackage

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

A flexible, reusable mini-map component for SpriteKit games that supports multiple entity types with customizable markers and positioning.

## Features

- **Multiple Entity Types**: Display any number of different entity types simultaneously
- **Type-Safe API**: Uses Swift's type system for compile-time safety
- **Customizable Markers**: Each entity type can have its own visual appearance
- **Predefined Positions**: 9 common window locations with easy setup
- **Flexible Sizing**: 4 predefined sizes plus custom sizing
- **Camera View Frame**: Shows current camera viewport on the mini-map
- **Click Handling**: Converts mini-map clicks to scene coordinates
- **Cross-Platform**: Supports iOS, macOS, tvOS, and watchOS
- **Zero Dependencies**: Pure Swift with only SpriteKit dependency

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the package to your Xcode project:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the package URL: `https://github.com/Atothendrew/MiniMapPackage.git`
3. Select the version you want to use
4. Click **Add Package**

### Manual Installation

1. Clone the repository
2. Add the `MiniMapPackage` folder to your Xcode project
3. Link against SpriteKit framework

## Quick Start

### 1. Define Your Entity Types

Create entity types that conform to `MiniMapEntity`:

```swift
import MiniMapPackage

struct Worker: MiniMapEntity {
    let position: CGPoint
    let isActive: Bool
    var markerColor: PlatformColor { isActive ? .green : .red }
    var markerRadius: CGFloat { 1.5 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 0.5 }
}

struct Gold: MiniMapEntity {
    let position: CGPoint
    let value: Int
    var markerColor: PlatformColor { .yellow }
    var markerRadius: CGFloat { 1.0 }
    var markerStrokeColor: PlatformColor { .orange }
    var markerLineWidth: CGFloat { 0.5 }
}
```

### 2. Create the Mini-Map

```swift
import SpriteKit
import MiniMapPackage

class GameScene: SKScene {
    private var miniMap: MiniMap!
    
    override func didMove(to view: SKView) {
        // Create mini-map in top-right corner with medium size
        miniMap = MiniMap(size: .medium, location: .topRight, in: size)
        miniMap.delegate = self
        addChild(miniMap)
    }
}
```

### 3. Update Entity Positions

```swift
extension GameScene {
    func updateMiniMap() {
        // Update base position
        miniMap.updateBasePosition(base.position, sceneSize: size)
        
        // Combine all entity types
        let workers: [Worker] = getWorkers()
        let golds: [Gold] = getGoldPieces()
        let enemies: [Enemy] = getEnemies()
        
        let allEntities: [AnyMiniMapEntity] =
            workers.map(AnyMiniMapEntity.init) +
            golds.map(AnyMiniMapEntity.init) +
            enemies.map(AnyMiniMapEntity.init)
        
        miniMap.updateEntityPositions(allEntities, sceneSize: size)
        
        // Update camera view frame
        miniMap.updateCameraViewFrame(
            cameraPosition: camera.position,
            cameraZoom: camera.xScale,
            sceneSize: size
        )
    }
}
```

### 4. Handle Mini-Map Clicks

```swift
extension GameScene: MiniMapDelegate {
    func miniMapClicked(at position: CGPoint) {
        // Move camera to clicked position
        let moveAction = SKAction.move(to: position, duration: 0.5)
        camera?.run(moveAction)
    }
}
```

## API Reference

### MiniMapLocation

Predefined window locations for easy positioning:

```swift
public enum MiniMapLocation {
    case topLeft      // Top-left corner
    case topRight     // Top-right corner
    case bottomLeft   // Bottom-left corner
    case bottomRight  // Bottom-right corner
    case topCenter    // Top center
    case bottomCenter // Bottom center
    case centerLeft   // Left center
    case centerRight  // Right center
    case center       // Center of screen
}
```

### MiniMapSize

Predefined sizes for common use cases:

```swift
public enum MiniMapSize {
    case small        // 150x100
    case medium       // 200x150
    case large        // 300x200
    case custom(CGSize) // Custom size
}
```

### MiniMapEntity Protocol

Entities that can be displayed on the mini-map:

```swift
public protocol MiniMapEntity {
    var position: CGPoint { get }
    var markerColor: PlatformColor { get }
    var markerRadius: CGFloat { get }
    var markerStrokeColor: PlatformColor { get }
    var markerLineWidth: CGFloat { get }
}
```

### MiniMap Class

Main mini-map component:

```swift
public class MiniMap: SKNode {
    // Initializers
    public init(size: CGSize)
    public convenience init(size: MiniMapSize, location: MiniMapLocation, in sceneSize: CGSize, margin: CGFloat = 20)
    
    // Configuration
    public var backgroundColor: PlatformColor
    public var backgroundStrokeColor: PlatformColor
    public var backgroundLineWidth: CGFloat
    public var backgroundAlpha: CGFloat
    public var cameraFrameColor: PlatformColor
    public var cameraFrameLineWidth: CGFloat
    public var cameraFrameAlpha: CGFloat
    public var miniMapZPosition: CGFloat
    
    // Delegate
    public weak var delegate: MiniMapDelegate?
    
    // Methods
    public func updateBasePosition(_ position: CGPoint, sceneSize: CGSize)
    public func updateEntityPositions(_ entities: [AnyMiniMapEntity], sceneSize: CGSize)
    public func updateCameraViewFrame(cameraPosition: CGPoint, cameraZoom: CGFloat, sceneSize: CGSize)
    public func handleClick(at location: CGPoint)
    public override func contains(_ point: CGPoint) -> Bool
}
```

### MiniMapDelegate Protocol

Handle mini-map interactions:

```swift
public protocol MiniMapDelegate: AnyObject {
    func miniMapClicked(at position: CGPoint)
}
```

## Advanced Usage

### Custom Styling

```swift
miniMap.backgroundColor = SKColor.black.withAlphaComponent(0.8)
miniMap.backgroundStrokeColor = SKColor.white
miniMap.backgroundLineWidth = 3.0
miniMap.cameraFrameColor = SKColor.cyan
miniMap.cameraFrameLineWidth = 2.0
```

### Multiple Entity Types

```swift
struct Player: MiniMapEntity {
    let position: CGPoint
    let health: Int
    var markerColor: PlatformColor { health > 50 ? .green : .red }
    var markerRadius: CGFloat { 2.0 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 1.0 }
}

struct Resource: MiniMapEntity {
    let position: CGPoint
    let type: ResourceType
    var markerColor: PlatformColor {
        switch type {
        case .wood: return .brown
        case .stone: return .gray
        case .ore: return .orange
        }
    }
    var markerRadius: CGFloat { 1.0 }
    var markerStrokeColor: PlatformColor { .black }
    var markerLineWidth: CGFloat { 0.5 }
}
```

### Dynamic Positioning

```swift
// Position based on screen size
let isLandscape = size.width > size.height
let location: MiniMapLocation = isLandscape ? .centerRight : .topRight
miniMap = MiniMap(size: .medium, location: location, in: size)
```

## Examples

### Basic Example

See the included example app for a complete working implementation:

```bash
cd Examples/MiniMapExampleApp
swift run
```

### Integration with GatherGame

The package is already integrated into the GatherGame project, demonstrating real-world usage with multiple entity types.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Troubleshooting

### Common Issues

**Build Errors**
- Ensure you're using Swift 5.9+ and Xcode 15.0+
- Clean build folder: `swift package clean`
- Reset package cache: `swift package reset`

**Runtime Issues**
- Make sure your entities conform to `MiniMapEntity` protocol
- Verify scene coordinates are within expected bounds
- Check that mini-map is added to the scene before updating positions

**Platform-Specific Notes**
- On macOS, Y coordinates may be inverted compared to iOS
- Some platforms may have different touch/click handling
- Test on target platforms before release

### Getting Help

- Check the [examples](Examples/) for working implementations
- Review the [API documentation](#api-reference) for detailed usage
- Open an [issue](https://github.com/Atothendrew/MiniMapPackage/issues) for bugs
- Start a [discussion](https://github.com/Atothendrew/MiniMapPackage/discussions) for questions

## Acknowledgments

- Built for SpriteKit game development
- Inspired by the need for flexible mini-map solutions
- Designed with cross-platform compatibility in mind

## Changelog

### Version 1.0.0
- Initial release
- Support for multiple entity types
- Predefined locations and sizes
- Camera view frame
- Click handling
- Cross-platform support 