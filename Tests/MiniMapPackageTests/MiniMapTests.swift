//
//  MiniMapTests.swift
//  MiniMapPackageTests
//
//  Created by Andrew Williamson on 7/16/25.
//

import SpriteKit
import XCTest

@testable import MiniMapPackage

final class MiniMapTests: XCTestCase {

  var miniMap: MiniMap!
  var scene: SKScene!

  override func setUp() {
    super.setUp()
    scene = SKScene(size: CGSize(width: 1000, height: 800))
    miniMap = MiniMap(size: CGSize(width: 200, height: 150))
    scene.addChild(miniMap)
  }

  override func tearDown() {
    miniMap = nil
    scene = nil
    super.tearDown()
  }

  func testMiniMapInitialization() {
    XCTAssertNotNil(miniMap)
    XCTAssertEqual(miniMap.children.count, 3)  // background, baseMarker, cameraViewFrame
    XCTAssertEqual(miniMap.zPosition, 1000)
  }

  func testContainsPoint() {
    let pointInside = CGPoint(x: 100, y: 75)
    let pointOutside = CGPoint(x: 300, y: 200)

    XCTAssertTrue(miniMap.contains(pointInside))
    XCTAssertFalse(miniMap.contains(pointOutside))
  }

  func testUpdateBasePosition() {
    let basePosition = CGPoint(x: 500, y: 400)
    miniMap.updateBasePosition(basePosition, sceneSize: scene.size)

    // The base marker should be positioned at the converted map coordinates
    let expectedMapPosition = CGPoint(x: 100, y: 75)  // 500 * 200/1000, 400 * 150/800
    XCTAssertEqual(
      miniMap.children.first { $0 is SKShapeNode && $0 != miniMap.background }?.position,
      expectedMapPosition)
  }

  func testUpdateEntityPositions() {
    let workers = [
      TestEntity(position: CGPoint(x: 100, y: 100), color: .red),
      TestEntity(position: CGPoint(x: 200, y: 200), color: .blue),
    ]
    let golds = [
      TestGold(position: CGPoint(x: 300, y: 300))
    ]
    let allEntities: [AnyMiniMapEntity] =
      workers.map(AnyMiniMapEntity.init) + golds.map(AnyMiniMapEntity.init)

    miniMap.updateEntityPositions(allEntities, sceneSize: scene.size)

    // Should have 3 entity markers plus background, base marker, and camera frame
    XCTAssertEqual(miniMap.children.count, 6)
  }

  func testUpdateEntityPositionsWithMixedTypes() {
    let workers = [TestEntity(position: CGPoint(x: 100, y: 100), color: .red)]
    let golds = [TestGold(position: CGPoint(x: 300, y: 300))]
    let enemies = [TestEnemy(position: CGPoint(x: 400, y: 400))]
    let allEntities: [AnyMiniMapEntity] =
      workers.map(AnyMiniMapEntity.init) + golds.map(AnyMiniMapEntity.init)
      + enemies.map(AnyMiniMapEntity.init)
    miniMap.updateEntityPositions(allEntities, sceneSize: scene.size)
    // Should have 3 entity markers plus background, base marker, and camera frame
    XCTAssertEqual(miniMap.children.count, 6)
  }

  func testUpdateCameraViewFrame() {
    let cameraPosition = CGPoint(x: 500, y: 400)
    let cameraZoom: CGFloat = 0.5

    miniMap.updateCameraViewFrame(
      cameraPosition: cameraPosition, cameraZoom: cameraZoom, sceneSize: scene.size)

    // Camera frame should be visible when zoomed in
    let cameraFrame =
      miniMap.children.first { node in
        guard let shapeNode = node as? SKShapeNode else { return false }
        return shapeNode.strokeColor == .cyan
      } as? SKShapeNode
    XCTAssertFalse(cameraFrame?.isHidden ?? true)
  }

  func testCameraViewFrameHiddenWhenZoomedOut() {
    let cameraPosition = CGPoint(x: 500, y: 400)
    let cameraZoom: CGFloat = 1.5

    miniMap.updateCameraViewFrame(
      cameraPosition: cameraPosition, cameraZoom: cameraZoom, sceneSize: scene.size)

    // Camera frame should be visible when zoomed out (we removed the hiding logic)
    let cameraFrame =
      miniMap.children.first { node in
        guard let shapeNode = node as? SKShapeNode else { return false }
        return shapeNode.strokeColor == .cyan
      } as? SKShapeNode
    XCTAssertFalse(cameraFrame?.isHidden ?? true)
  }

  func testDelegateCallback() {
    let expectation = XCTestExpectation(description: "Delegate should be called")

    class TestDelegate: MiniMapDelegate {
      let expectation: XCTestExpectation

      init(expectation: XCTestExpectation) {
        self.expectation = expectation
      }

      func miniMapClicked(at position: CGPoint) {
        expectation.fulfill()
      }
    }

    let delegate = TestDelegate(expectation: expectation)
    miniMap.delegate = delegate

    // Simulate a click on the mini-map
    let clickPosition = CGPoint(x: 100, y: 75)
    miniMap.handleClick(at: clickPosition)

    wait(for: [expectation], timeout: 1.0)
  }

  func testCustomization() {
    miniMap.backgroundColor = SKColor.darkGray
    miniMap.backgroundStrokeColor = SKColor.yellow
    miniMap.backgroundLineWidth = 5.0
    miniMap.backgroundAlpha = 0.5
    miniMap.cameraFrameColor = SKColor.magenta
    miniMap.cameraFrameLineWidth = 3.0
    miniMap.cameraFrameAlpha = 0.3
    miniMap.zPosition = 2000

    XCTAssertEqual(miniMap.backgroundColor, SKColor.darkGray)
    XCTAssertEqual(miniMap.backgroundStrokeColor, SKColor.yellow)
    XCTAssertEqual(miniMap.backgroundLineWidth, 5.0)
    XCTAssertEqual(miniMap.backgroundAlpha, 0.5)
    XCTAssertEqual(miniMap.cameraFrameColor, SKColor.magenta)
    XCTAssertEqual(miniMap.cameraFrameLineWidth, 3.0)
    XCTAssertEqual(miniMap.cameraFrameAlpha, 0.3)
    XCTAssertEqual(miniMap.zPosition, 2000)
  }
}

// MARK: - Test Entity

struct TestEntity: MiniMapEntity {
  let position: CGPoint
  let color: PlatformColor

  var markerColor: PlatformColor { color }
  var markerRadius: CGFloat { 2.0 }
  var markerStrokeColor: PlatformColor { .white }
  var markerLineWidth: CGFloat { 1.0 }
}

struct TestGold: MiniMapEntity {
  let position: CGPoint
  var markerColor: PlatformColor { .yellow }
  var markerRadius: CGFloat { 1.0 }
  var markerStrokeColor: PlatformColor { .orange }
  var markerLineWidth: CGFloat { 0.5 }
}

struct TestEnemy: MiniMapEntity {
  let position: CGPoint
  var markerColor: PlatformColor { .purple }
  var markerRadius: CGFloat { 2.0 }
  var markerStrokeColor: PlatformColor { .white }
  var markerLineWidth: CGFloat { 1.0 }
}
