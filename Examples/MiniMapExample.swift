//
//  MiniMapExample.swift
//  MiniMapPackage
//
//  Example usage of the MiniMap package
//

import MiniMapPackage
import SpriteKit

// MARK: - Example Entity Types

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

// MARK: - Example Game Scene

class ExampleGameScene: SKScene {
  private var miniMap: MiniMap!
  private var workers: [Worker] = []
  private var goldPieces: [Gold] = []
  private var enemies: [Enemy] = []

  override func didMove(to view: SKView) {
    setupMiniMap()
    setupEntities()
    updateMiniMap()
  }

  private func setupMiniMap() {
    miniMap = MiniMap(size: CGSize(width: 200, height: 150))
    miniMap.position = CGPoint(x: size.width - 220, y: size.height - 170)
    miniMap.delegate = self
    // Customize appearance
    miniMap.backgroundColor = SKColor.darkGray
    miniMap.backgroundStrokeColor = SKColor.white
    miniMap.backgroundLineWidth = 3.0
    miniMap.backgroundAlpha = 0.9
    miniMap.cameraFrameColor = SKColor.cyan
    miniMap.cameraFrameLineWidth = 2.0
    miniMap.cameraFrameAlpha = 0.8
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

  func updateMiniMap() {
    // Update base position (assuming you have a base)
    let basePosition = CGPoint(x: 50, y: 50)
    miniMap.updateBasePosition(basePosition, sceneSize: size)
    // Combine all entity types
    let allEntities: [AnyMiniMapEntity] =
      workers.map(AnyMiniMapEntity.init) + goldPieces.map(AnyMiniMapEntity.init)
      + enemies.map(AnyMiniMapEntity.init)
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

// MARK: - MiniMap Delegate

extension ExampleGameScene: MiniMapDelegate {
  func miniMapClicked(at position: CGPoint) {
    // Move camera to clicked position
    let moveAction = SKAction.move(to: position, duration: 0.5)
    camera?.run(moveAction)
  }
}
