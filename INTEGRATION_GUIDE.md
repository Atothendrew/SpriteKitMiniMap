# MiniMapPackage Integration Guide

A comprehensive guide for integrating the MiniMapPackage into your SpriteKit games and applications.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Basic Integration](#basic-integration)
3. [Advanced Usage](#advanced-usage)
4. [Platform-Specific Considerations](#platform-specific-considerations)
5. [Customization](#customization)
6. [Performance Optimization](#performance-optimization)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)
9. [Examples](#examples)

## Quick Start

### Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Atothendrew/MiniMapPackage.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter URL.

### Basic Setup

```swift
import SpriteKit
import MiniMapPackage

class GameScene: SKScene {
    private var miniMap: MiniMap!
    
    override func didMove(to view: SKView) {
        // Create mini-map
        miniMap = MiniMap(size: CGSize(width: 200, height: 150))
        miniMap.position = CGPoint(x: 50, y: 50)
        addChild(miniMap)
        
        // Set delegate for click handling
        miniMap.delegate = self
    }
}

extension GameScene: MiniMapDelegate {
    func miniMapClicked(at position: CGPoint) {
        // Handle mini-map clicks
        print("Mini-map clicked at: \(position)")
    }
}
```

## Basic Integration

### 1. Creating Your First Mini-Map

```swift
// Create with custom size
let miniMap = MiniMap(size: CGSize(width: 250, height: 180))

// Position in your scene
miniMap.position = CGPoint(x: 20, y: 20)
scene.addChild(miniMap)
```

### 2. Adding Entities

Create entities that conform to `MiniMapEntity`:

```swift
struct Player: MiniMapEntity {
    let position: CGPoint
    var markerColor: PlatformColor { .blue }
    var markerRadius: CGFloat { 3.0 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 1.0 }
}

struct Enemy: MiniMapEntity {
    let position: CGPoint
    var markerColor: PlatformColor { .red }
    var markerRadius: CGFloat { 2.0 }
    var markerStrokeColor: PlatformColor { .black }
    var markerLineWidth: CGFloat { 0.5 }
}

struct Collectible: MiniMapEntity {
    let position: CGPoint
    var markerColor: PlatformColor { .yellow }
    var markerRadius: CGFloat { 1.5 }
    var markerStrokeColor: PlatformColor { .orange }
    var markerLineWidth: CGFloat { 0.5 }
}
```

### 3. Updating Entity Positions

```swift
// Update entities every frame or when positions change
func updateMiniMap() {
    let entities: [AnyMiniMapEntity] = [
        AnyMiniMapEntity(Player(position: player.position)),
        AnyMiniMapEntity(Enemy(position: enemy.position)),
        AnyMiniMapEntity(Collectible(position: collectible.position))
    ]
    
    miniMap.updateEntityPositions(entities, sceneSize: scene.size)
}
```

### 4. Camera View Frame

```swift
// Update camera view frame to show current viewport
func updateCameraView() {
    miniMap.updateCameraViewFrame(
        cameraPosition: camera.position,
        cameraZoom: camera.xScale,
        sceneSize: scene.size
    )
}
```

## Advanced Usage

### 1. Mouse Event Integration

For complete mouse interaction support, implement these methods in your scene:

```swift
class GameScene: SKScene {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        // Let mini-map handle mouse events first
        if miniMap.handleMouseDown(at: location, in: self) {
            return // Mini-map handled the event
        }
        
        // Handle other game interactions
        handleGameMouseDown(at: location)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseDragged(to: location, in: self) {
            return
        }
        
        handleGameMouseDragged(to: location)
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseUp(at: location, in: self) {
            return
        }
        
        handleGameMouseUp(at: location)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleRightMouseDown(at: location, in: self) {
            return
        }
        
        handleGameRightMouseDown(at: location)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseMoved(to: location, in: self) {
            return
        }
        
        handleGameMouseMoved(to: location)
    }
}
```

### 2. Touch Event Integration (iOS)

```swift
class GameScene: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if miniMap.handleMouseDown(at: location, in: self) {
            return
        }
        
        handleGameTouchBegan(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if miniMap.handleMouseDragged(to: location, in: self) {
            return
        }
        
        handleGameTouchMoved(to: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if miniMap.handleMouseUp(at: location, in: self) {
            return
        }
        
        handleGameTouchEnded(at: location)
    }
}
```

### 3. Dynamic Entity Management

```swift
class GameScene: SKScene {
    private var gameEntities: [GameEntity] = []
    
    func addEntity(_ entity: GameEntity) {
        gameEntities.append(entity)
        updateMiniMap()
    }
    
    func removeEntity(_ entity: GameEntity) {
        gameEntities.removeAll { $0.id == entity.id }
        updateMiniMap()
    }
    
    func updateMiniMap() {
        let miniMapEntities: [AnyMiniMapEntity] = gameEntities.map { entity in
            switch entity.type {
            case .player:
                return AnyMiniMapEntity(Player(position: entity.position))
            case .enemy:
                return AnyMiniMapEntity(Enemy(position: entity.position))
            case .collectible:
                return AnyMiniMapEntity(Collectible(position: entity.position))
            }
        }
        
        miniMap.updateEntityPositions(miniMapEntities, sceneSize: scene.size)
    }
}
```

## Platform-Specific Considerations

### macOS

```swift
// Enable mouse tracking for hover effects
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.acceptsMouseMovedEvents = true
        }
    }
}

// In your SKView setup
skView.allowsTransparency = true
skView.ignoresSiblingOrder = true
```

### iOS

```swift
// Ensure proper touch handling
class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
```

### tvOS

```swift
// Focus-based navigation
class GameScene: SKScene {
    override func didMove(to view: SKView) {
        // Set up focus for tvOS
        miniMap.isUserInteractionEnabled = true
    }
}
```

## Customization

### 1. Visual Customization

```swift
// Customize mini-map appearance
miniMap.backgroundColor = SKColor.darkGray
miniMap.backgroundStrokeColor = SKColor.yellow
miniMap.backgroundLineWidth = 3.0
miniMap.backgroundAlpha = 0.8

miniMap.cameraFrameColor = SKColor.cyan
miniMap.cameraFrameLineWidth = 2.0
miniMap.cameraFrameAlpha = 0.6

miniMap.zPosition = 1000
```

### 2. Custom Entity Types

```swift
struct Boss: MiniMapEntity {
    let position: CGPoint
    var markerColor: PlatformColor { .purple }
    var markerRadius: CGFloat { 4.0 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 2.0 }
}

struct Portal: MiniMapEntity {
    let position: CGPoint
    var markerColor: PlatformColor { .green }
    var markerRadius: CGFloat { 2.5 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 1.5 }
}
```

### 3. Dynamic Entity Properties

```swift
struct DynamicEntity: MiniMapEntity {
    let position: CGPoint
    let health: CGFloat
    let maxHealth: CGFloat
    
    var markerColor: PlatformColor {
        let healthRatio = health / maxHealth
        if healthRatio > 0.7 { return .green }
        if healthRatio > 0.3 { return .yellow }
        return .red
    }
    
    var markerRadius: CGFloat { 2.0 }
    var markerStrokeColor: PlatformColor { .white }
    var markerLineWidth: CGFloat { 1.0 }
}
```

## Performance Optimization

### 1. Efficient Updates

```swift
class GameScene: SKScene {
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 1.0 / 30.0 // 30 FPS
    
    override func update(_ currentTime: TimeInterval) {
        // Update mini-map at reduced frequency
        if currentTime - lastUpdateTime > updateInterval {
            updateMiniMap()
            lastUpdateTime = currentTime
        }
    }
}
```

### 2. Entity Pooling

```swift
class EntityManager {
    private var entityPool: [AnyMiniMapEntity] = []
    
    func getEntity(for gameEntity: GameEntity) -> AnyMiniMapEntity {
        // Reuse existing entities when possible
        if let existing = entityPool.first(where: { /* match criteria */ }) {
            return existing
        }
        
        let newEntity = createMiniMapEntity(for: gameEntity)
        entityPool.append(newEntity)
        return newEntity
    }
}
```

### 3. Culling

```swift
func updateMiniMapWithCulling() {
    let visibleEntities = gameEntities.filter { entity in
        // Only show entities within a certain distance
        let distance = hypot(entity.position.x - camera.position.x,
                           entity.position.y - camera.position.y)
        return distance < maxVisibleDistance
    }
    
    let miniMapEntities = visibleEntities.map { /* convert to mini-map entities */ }
    miniMap.updateEntityPositions(miniMapEntities, sceneSize: scene.size)
}
```

## Troubleshooting

### Common Issues

#### 1. Mini-map not responding to clicks

**Problem**: Mini-map doesn't detect mouse/touch events.

**Solution**:
```swift
// Ensure proper event handling order
override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Check if mini-map contains the point
    if miniMap.contains(location) {
        if miniMap.handleMouseDown(at: location, in: self) {
            return
        }
    }
    
    // Handle other interactions
}
```

#### 2. Entities not appearing on mini-map

**Problem**: Entities don't show up or appear in wrong positions.

**Solution**:
```swift
// Ensure proper coordinate conversion
func updateEntityPositions() {
    let entities = gameEntities.map { entity in
        // Use scene coordinates, not local coordinates
        let scenePosition = entity.convert(.zero, to: scene)
        return AnyMiniMapEntity(Player(position: scenePosition))
    }
    
    miniMap.updateEntityPositions(entities, sceneSize: scene.size)
}
```

#### 3. Mini-map dragging not smooth

**Problem**: Dragging feels jittery or unresponsive.

**Solution**:
```swift
// Ensure proper mouse tracking
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.acceptsMouseMovedEvents = true
        }
    }
}
```

#### 4. Camera frame not updating

**Problem**: Camera view frame doesn't reflect current viewport.

**Solution**:
```swift
// Update camera frame with correct parameters
func updateCameraView() {
    let cameraPosition = camera.position
    let cameraZoom = camera.xScale // Use xScale for uniform scaling
    
    miniMap.updateCameraViewFrame(
        cameraPosition: cameraPosition,
        cameraZoom: cameraZoom,
        sceneSize: scene.size
    )
}
```

### Debug Tips

```swift
// Enable debug visualization
miniMap.backgroundColor = SKColor.red.withAlphaComponent(0.3)
miniMap.backgroundStrokeColor = SKColor.white
miniMap.backgroundLineWidth = 2.0

// Add debug information
print("Mini-map position: \(miniMap.position)")
print("Mini-map size: \(miniMap.frame.size)")
print("Scene size: \(scene.size)")
```

## Best Practices

### 1. Event Handling Order

```swift
// Always check mini-map first in event handlers
override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Priority 1: Mini-map interactions
    if miniMap.handleMouseDown(at: location, in: self) {
        return
    }
    
    // Priority 2: UI elements
    if handleUIInteraction(at: location) {
        return
    }
    
    // Priority 3: Game interactions
    handleGameInteraction(at: location)
}
```

### 2. Entity Management

```swift
// Use type-safe entity creation
enum EntityType {
    case player, enemy, collectible, boss
}

func createMiniMapEntity(type: EntityType, position: CGPoint) -> AnyMiniMapEntity {
    switch type {
    case .player:
        return AnyMiniMapEntity(Player(position: position))
    case .enemy:
        return AnyMiniMapEntity(Enemy(position: position))
    case .collectible:
        return AnyMiniMapEntity(Collectible(position: position))
    case .boss:
        return AnyMiniMapEntity(Boss(position: position))
    }
}
```

### 3. Performance Monitoring

```swift
class MiniMapManager {
    private var updateCount = 0
    private var lastPerformanceCheck = Date()
    
    func updateMiniMap() {
        updateCount += 1
        
        // Performance monitoring
        let now = Date()
        if now.timeIntervalSince(lastPerformanceCheck) > 1.0 {
            print("Mini-map updates per second: \(updateCount)")
            updateCount = 0
            lastPerformanceCheck = now
        }
        
        // Actual update logic
        // ...
    }
}
```

## Examples

### Complete Game Scene Example

```swift
import SpriteKit
import MiniMapPackage

class GameScene: SKScene {
    private var miniMap: MiniMap!
    private var player: SKSpriteNode!
    private var enemies: [SKSpriteNode] = []
    private var collectibles: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        setupMiniMap()
        setupGameEntities()
        setupCamera()
    }
    
    private func setupMiniMap() {
        miniMap = MiniMap(size: CGSize(width: 200, height: 150))
        miniMap.position = CGPoint(x: 20, y: 20)
        miniMap.delegate = self
        miniMap.backgroundColor = SKColor.darkGray
        miniMap.backgroundAlpha = 0.8
        addChild(miniMap)
    }
    
    private func setupGameEntities() {
        // Create player
        player = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20))
        player.position = CGPoint(x: 100, y: 100)
        addChild(player)
        
        // Create enemies
        for i in 0..<5 {
            let enemy = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
            enemy.position = CGPoint(x: CGFloat.random(in: 50...400),
                                   y: CGFloat.random(in: 50...300))
            enemies.append(enemy)
            addChild(enemy)
        }
        
        // Create collectibles
        for i in 0..<3 {
            let collectible = SKSpriteNode(color: .yellow, size: CGSize(width: 10, height: 10))
            collectible.position = CGPoint(x: CGFloat.random(in: 50...400),
                                         y: CGFloat.random(in: 50...300))
            collectibles.append(collectible)
            addChild(collectible)
        }
    }
    
    private func setupCamera() {
        camera = SKCameraNode()
        addChild(camera)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateMiniMap()
        updateCamera()
    }
    
    private func updateMiniMap() {
        let entities: [AnyMiniMapEntity] = [
            AnyMiniMapEntity(Player(position: player.position)),
        ] + enemies.map { AnyMiniMapEntity(Enemy(position: $0.position)) } +
        collectibles.map { AnyMiniMapEntity(Collectible(position: $0.position)) }
        
        miniMap.updateEntityPositions(entities, sceneSize: size)
    }
    
    private func updateCamera() {
        // Follow player
        camera.position = player.position
        
        // Update mini-map camera frame
        miniMap.updateCameraViewFrame(
            cameraPosition: camera.position,
            cameraZoom: camera.xScale,
            sceneSize: size
        )
    }
}

extension GameScene: MiniMapDelegate {
    func miniMapClicked(at position: CGPoint) {
        // Convert mini-map position to scene position
        let scenePosition = convertMiniMapPositionToScene(position)
        
        // Move player to clicked position
        let moveAction = SKAction.move(to: scenePosition, duration: 1.0)
        player.run(moveAction)
    }
    
    private func convertMiniMapPositionToScene(_ miniMapPosition: CGPoint) -> CGPoint {
        // Convert mini-map coordinates to scene coordinates
        let scaleX = size.width / miniMap.mapSize.width
        let scaleY = size.height / miniMap.mapSize.height
        
        return CGPoint(
            x: miniMapPosition.x * scaleX,
            y: miniMapPosition.y * scaleY
        )
    }
}

// Mouse event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseDown(at: location, in: self) {
            return
        }
        
        // Handle other game interactions
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseDragged(to: location, in: self) {
            return
        }
        
        // Handle other game interactions
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseUp(at: location, in: self) {
            return
        }
        
        // Handle other game interactions
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        
        if miniMap.handleMouseMoved(to: location, in: self) {
            return
        }
        
        // Handle other game interactions
    }
}
```

This comprehensive integration guide covers all aspects of using the MiniMapPackage, from basic setup to advanced optimization techniques. The examples and troubleshooting sections should help you integrate the mini-map successfully into your SpriteKit projects. 