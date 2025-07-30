import Cocoa
import MiniMapPackage
import SpriteKit

// Copy the example code here
struct Worker: MiniMapEntity {
  let position: CGPoint
  let isActive: Bool
  let type: WorkerType

  enum WorkerType {
    case miner, builder, scout
  }

  var markerColor: PlatformColor {
    switch type {
    case .miner: return isActive ? SKColor.green : SKColor(red: 0, green: 0.3, blue: 0, alpha: 1)
    case .builder: return isActive ? SKColor.blue : SKColor(red: 0, green: 0, blue: 0.3, alpha: 1)
    case .scout: return isActive ? SKColor.orange : SKColor(red: 0.5, green: 0.3, blue: 0, alpha: 1)
    }
  }
  var markerRadius: CGFloat { 1.5 }
  var markerStrokeColor: PlatformColor { SKColor.white }
  var markerLineWidth: CGFloat { 0.5 }
}

struct Gold: MiniMapEntity {
  let position: CGPoint
  let value: Int
  var markerColor: PlatformColor { SKColor.yellow }
  var markerRadius: CGFloat { 1.0 }
  var markerStrokeColor: PlatformColor { SKColor.orange }
  var markerLineWidth: CGFloat { 0.5 }
}

struct Enemy: MiniMapEntity {
  let position: CGPoint
  let threatLevel: ThreatLevel
  enum ThreatLevel {
    case low, medium, high
  }
  var markerColor: PlatformColor {
    switch threatLevel {
    case .low: return SKColor.orange
    case .medium: return SKColor.red
    case .high: return SKColor.purple
    }
  }
  var markerRadius: CGFloat { 2.0 }
  var markerStrokeColor: PlatformColor { SKColor.white }
  var markerLineWidth: CGFloat { 1.0 }
}

class ExampleGameScene: SKScene {
  private var miniMap: MiniMap!
  private var currentPositionIndex = 0
  private var workers: [Worker] = []
  private var goldPieces: [Gold] = []
  private var enemies: [Enemy] = []
  private var positionLabel: SKLabelNode!

  override func didMove(to view: SKView) {
    setupMiniMap()
    setupEntities()
    updateMiniMap()

    // Add some visual elements to the scene
    addVisualElements()
    addPositionLabel()
  }

  private func setupMiniMap() {
    let positions: [MiniMapLocation] = [
      .topLeft, .topRight, .bottomLeft, .bottomRight,
      .topCenter, .bottomCenter, .centerLeft, .centerRight, .center,
    ]

    let currentPosition = positions[currentPositionIndex]
    miniMap = MiniMap(size: .medium, location: currentPosition, in: size)
    miniMap.delegate = self
    // Customize appearance
    miniMap.backgroundColor = SKColor.darkGray
    miniMap.backgroundStrokeColor = SKColor.white
    miniMap.backgroundLineWidth = 2.0
    miniMap.backgroundAlpha = 0.8
    miniMap.cameraFrameColor = SKColor.cyan
    miniMap.cameraFrameLineWidth = 1.5
    miniMap.cameraFrameAlpha = 0.7
    addChild(miniMap)
  }

  private func setupEntities() {
    // Create some example entities
    workers = [
      Worker(position: CGPoint(x: 100, y: 100), isActive: true, type: .miner),
      Worker(position: CGPoint(x: 200, y: 150), isActive: false, type: .builder),
      Worker(position: CGPoint(x: 300, y: 200), isActive: true, type: .scout),
    ]
    goldPieces = [
      Gold(position: CGPoint(x: 150, y: 120), value: 10),
      Gold(position: CGPoint(x: 250, y: 180), value: 25),
      Gold(position: CGPoint(x: 350, y: 250), value: 50),
    ]
    enemies = [
      Enemy(position: CGPoint(x: 400, y: 300), threatLevel: .low),
      Enemy(position: CGPoint(x: 500, y: 350), threatLevel: .medium),
      Enemy(position: CGPoint(x: 600, y: 400), threatLevel: .high),
    ]
  }

  private func addVisualElements() {
    // Add visual representations of entities
    for worker in workers {
      let node = SKShapeNode(circleOfRadius: 5)
      node.position = worker.position
      node.fillColor = worker.markerColor
      node.strokeColor = worker.markerStrokeColor
      node.lineWidth = worker.markerLineWidth
      addChild(node)
    }

    for gold in goldPieces {
      let node = SKShapeNode(circleOfRadius: 3)
      node.position = gold.position
      node.fillColor = gold.markerColor
      node.strokeColor = gold.markerStrokeColor
      node.lineWidth = gold.markerLineWidth
      addChild(node)
    }

    for enemy in enemies {
      let node = SKShapeNode(circleOfRadius: 8)
      node.position = enemy.position
      node.fillColor = enemy.markerColor
      node.strokeColor = enemy.markerStrokeColor
      node.lineWidth = enemy.markerLineWidth
      addChild(node)
    }
  }

  private func addPositionLabel() {
    positionLabel = SKLabelNode(text: "Click to cycle positions")
    positionLabel.fontName = "Arial"
    positionLabel.fontSize = 18
    positionLabel.fontColor = SKColor.white
    positionLabel.position = CGPoint(x: size.width / 2, y: size.height - 30)
    positionLabel.zPosition = 1001
    addChild(positionLabel)
  }

  private func cycleToNextPosition() {
    let positions: [MiniMapLocation] = [
      .topLeft, .topRight, .bottomLeft, .bottomRight,
      .topCenter, .bottomCenter, .centerLeft, .centerRight, .center,
    ]

    let positionNames = [
      "Top Left", "Top Right", "Bottom Left", "Bottom Right",
      "Top Center", "Bottom Center", "Center Left", "Center Right", "Center",
    ]

    // Remove current mini-map
    miniMap.removeFromParent()

    // Move to next position
    currentPositionIndex = (currentPositionIndex + 1) % positions.count
    let newPosition = positions[currentPositionIndex]

    // Create new mini-map in new position
    miniMap = MiniMap(size: .medium, location: newPosition, in: size)
    miniMap.delegate = self
    // Customize appearance
    miniMap.backgroundColor = SKColor.darkGray
    miniMap.backgroundStrokeColor = SKColor.white
    miniMap.backgroundLineWidth = 2.0
    miniMap.backgroundAlpha = 0.8
    miniMap.cameraFrameColor = SKColor.cyan
    miniMap.cameraFrameLineWidth = 1.5
    miniMap.cameraFrameAlpha = 0.7
    addChild(miniMap)

    // Update label
    positionLabel.text = "Position: \(positionNames[currentPositionIndex]) - Click to cycle"

    // Update the mini-map with current data
    updateMiniMap()
  }

  func updateMiniMap() {
    // Update base position (assuming you have a base)
    let basePosition = CGPoint(x: 50, y: 50)

    // Combine all entity types
    let allEntities: [AnyMiniMapEntity] =
      workers.map(AnyMiniMapEntity.init) + goldPieces.map(AnyMiniMapEntity.init)
      + enemies.map(AnyMiniMapEntity.init)

    miniMap.updateBasePosition(basePosition, sceneSize: size)
    miniMap.updateEntityPositions(allEntities, sceneSize: size)
    // Update camera view frame
    if let camera = camera {
      miniMap.updateCameraViewFrame(
        cameraPosition: camera.position,
        cameraZoom: camera.xScale,
        sceneSize: size
      )
    }
  }
}

extension ExampleGameScene: MiniMapDelegate {
  func miniMapClicked(at position: CGPoint) {
    // Cycle to next position instead of moving camera
    cycleToNextPosition()
    }
  
  override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Handle mini-map interaction first
    if miniMap.handleMouseDown(at: location, in: self) {
      return
    }
    
    // Handle other game interactions here...
    // Example: shopManager.handleTouch(at: location, in: self)
  }
  
  override func mouseDragged(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Handle mini-map interaction first
    if miniMap.handleMouseDragged(to: location, in: self) {
      return
    }
    
    // Handle other game interactions here...
  }
  
  override func mouseUp(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Handle mini-map interaction first
    if miniMap.handleMouseUp(at: location, in: self) {
      return
    }
    
    // Handle other game interactions here...
  }
  
  override func rightMouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Handle mini-map interaction first
    if miniMap.handleRightMouseDown(at: location, in: self) {
      return
    }
    
    // Handle other game interactions here...
  }
  
  override func mouseMoved(with event: NSEvent) {
    let location = event.location(in: self)
    
    // Handle mini-map interaction first
    if miniMap.handleMouseMoved(to: location, in: self) {
      return
    }
    
    // Reset cursor if not over mini-map
    NSCursor.arrow.set()
  }
}

// MARK: - Main App

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  var skView: SKView!

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Set up the application properly
    NSApp.setActivationPolicy(.regular)

    // Create the window
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "MiniMap Example"
    window.center()
    window.makeKeyAndOrderFront(nil)

    // Create the SpriteKit view
    skView = SKView(frame: window.contentView!.bounds)
    skView.autoresizingMask = [.width, .height]
    window.contentView!.addSubview(skView)
    
    // Enable mouse tracking for hover effects
    skView.allowsTransparency = true
    skView.ignoresSiblingOrder = true

    // Create and present the scene
    let scene = ExampleGameScene(size: CGSize(width: 800, height: 600))
    scene.scaleMode = .aspectFit
    scene.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

    skView.presentScene(scene)
    skView.showsFPS = true
    skView.showsNodeCount = true
    
    // Enable mouse tracking for hover effects
    window.acceptsMouseMovedEvents = true

    // Activate the app
    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

// Start the application
let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
