//
//  MiniMap.swift
//  MiniMapPackage
//
//  Created by Andrew Williamson on 7/16/25.
//

import SpriteKit

// Use SKColor which is available across all platforms
public typealias PlatformColor = SKColor

// MARK: - Mini-map Delegate Protocol

/// Protocol for handling mini-map click events
public protocol MiniMapDelegate: AnyObject {
  /// Called when the mini-map is clicked
  /// - Parameter position: The scene coordinates corresponding to the clicked position on the mini-map
  func miniMapClicked(at position: CGPoint)
}

// MARK: - Default Window Locations and Sizes

/// Predefined window locations for easy positioning of the mini-map
public enum MiniMapLocation {
  /// Top-left corner of the screen
  case topLeft
  /// Top-right corner of the screen
  case topRight
  /// Bottom-left corner of the screen
  case bottomLeft
  /// Bottom-right corner of the screen
  case bottomRight
  /// Top center of the screen
  case topCenter
  /// Bottom center of the screen
  case bottomCenter
  /// Left center of the screen
  case centerLeft
  /// Right center of the screen
  case centerRight
  /// Center of the screen
  case center

  public func position(in sceneSize: CGSize, mapSize: CGSize, margin: CGFloat = 20) -> CGPoint {
    switch self {
    case .topLeft:
      return CGPoint(x: margin, y: sceneSize.height - mapSize.height - margin)
    case .topRight:
      return CGPoint(
        x: sceneSize.width - mapSize.width - margin, y: sceneSize.height - mapSize.height - margin)
    case .bottomLeft:
      return CGPoint(x: margin, y: margin)
    case .bottomRight:
      return CGPoint(x: sceneSize.width - mapSize.width - margin, y: margin)
    case .topCenter:
      return CGPoint(
        x: (sceneSize.width - mapSize.width) / 2, y: sceneSize.height - mapSize.height - margin)
    case .bottomCenter:
      return CGPoint(x: (sceneSize.width - mapSize.width) / 2, y: margin)
    case .centerLeft:
      return CGPoint(x: margin, y: (sceneSize.height - mapSize.height) / 2)
    case .centerRight:
      return CGPoint(
        x: sceneSize.width - mapSize.width - margin, y: (sceneSize.height - mapSize.height) / 2)
    case .center:
      return CGPoint(
        x: (sceneSize.width - mapSize.width) / 2, y: (sceneSize.height - mapSize.height) / 2)
    }
  }
}

/// Predefined sizes for common use cases
public enum MiniMapSize {
  /// Small size (150x100)
  case small
  /// Medium size (200x150)
  case medium
  /// Large size (300x200)
  case large
  /// Custom size with specified dimensions
  case custom(CGSize)

  public var size: CGSize {
    switch self {
    case .small:
      return CGSize(width: 150, height: 100)
    case .medium:
      return CGSize(width: 200, height: 150)
    case .large:
      return CGSize(width: 300, height: 200)
    case .custom(let size):
      return size
    }
  }
}

// MARK: - Entity Protocol

/// Protocol for entities that can be displayed on the mini-map
public protocol MiniMapEntity {
  /// The position of the entity in scene coordinates
  var position: CGPoint { get }
  /// The fill color of the entity's marker
  var markerColor: PlatformColor { get }
  /// The radius of the entity's marker
  var markerRadius: CGFloat { get }
  /// The stroke color of the entity's marker
  var markerStrokeColor: PlatformColor { get }
  /// The line width of the entity's marker stroke
  var markerLineWidth: CGFloat { get }
}

// MARK: - Default Entity Implementation

extension MiniMapEntity {
  public var markerColor: PlatformColor { .red }
  public var markerRadius: CGFloat { 1.0 }
  public var markerStrokeColor: PlatformColor { .white }
  public var markerLineWidth: CGFloat { 0.5 }
}

// MARK: - Base Entity

public struct BaseEntity: MiniMapEntity {
  public let position: CGPoint

  public init(position: CGPoint) {
    self.position = position
  }

  public var markerColor: PlatformColor { .blue }
  public var markerRadius: CGFloat { 3.0 }
  public var markerStrokeColor: PlatformColor { .white }
  public var markerLineWidth: CGFloat { 1.0 }
}

// MARK: - Type-Erased Entity Wrapper

public struct AnyMiniMapEntity: MiniMapEntity {
  private let _position: () -> CGPoint
  private let _markerColor: () -> PlatformColor
  private let _markerRadius: () -> CGFloat
  private let _markerStrokeColor: () -> PlatformColor
  private let _markerLineWidth: () -> CGFloat

  public var position: CGPoint { _position() }
  public var markerColor: PlatformColor { _markerColor() }
  public var markerRadius: CGFloat { _markerRadius() }
  public var markerStrokeColor: PlatformColor { _markerStrokeColor() }
  public var markerLineWidth: CGFloat { _markerLineWidth() }

  public init<E: MiniMapEntity>(_ entity: E) {
    _position = { entity.position }
    _markerColor = { entity.markerColor }
    _markerRadius = { entity.markerRadius }
    _markerStrokeColor = { entity.markerStrokeColor }
    _markerLineWidth = { entity.markerLineWidth }
  }
}

// MARK: - Mini-map

/// A flexible mini-map component for SpriteKit games
/// 
/// The MiniMap class provides a customizable overlay that displays entity positions
/// and camera view information. It supports multiple entity types, predefined
/// positioning, and interactive features like click handling and dragging.
/// The base marker is optional and can be enabled via the showBaseMarker property.
/// Position updates on click are optional and can be enabled via the updatePositionOnClick property.
public class MiniMap: SKNode {
  private var mapSize: CGSize
  internal let background: SKShapeNode
  private let baseMarker: SKShapeNode?
  private var entityMarkers: [SKShapeNode] = []
  private var cameraViewFrame: SKShapeNode?
  public weak var delegate: MiniMapDelegate?

  // Dragging and resizing properties
  private var isDragging = false
  private var isResizing = false
  private var dragStart: CGPoint = .zero
  private var dragOffset: CGPoint = .zero
  private var resizeStart: CGPoint = .zero
  private var originalSize: CGSize = .zero
  private var lastResizeTime: TimeInterval = 0
  private var lastDragTime: TimeInterval = 0
  private let resizeTimeout: TimeInterval = 5.0  // 5 seconds timeout
  private let dragTimeout: TimeInterval = 5.0  // 5 seconds timeout
  
  // Entity tracking for resize updates
  private var currentEntities: [AnyMiniMapEntity] = []
  private var currentSceneSize: CGSize = .zero
  


  // Default position and size for reset functionality
  public var defaultPosition: CGPoint = .zero
  public var defaultSize: CGSize = .zero

  // Configuration
  public var backgroundColor: PlatformColor = .black
  public var backgroundStrokeColor: PlatformColor = .white
  public var backgroundLineWidth: CGFloat = 2.0
  public var backgroundAlpha: CGFloat = 0.8
  public var cameraFrameColor: PlatformColor = .cyan
  public var cameraFrameLineWidth: CGFloat = 2.0
  public var cameraFrameAlpha: CGFloat = 0.7
  public var miniMapZPosition: CGFloat = 1000
  
  /// Whether to show the base marker on the mini-map
  /// When enabled, a blue circle will be displayed to represent the base position
  public var showBaseMarker: Bool = false
  
  /// Whether clicking on the mini-map should update the camera position
  /// When enabled, clicking on the mini-map will move the camera to that position
  public var updatePositionOnClick: Bool = false

  /// Initialize a mini-map with a custom size
  /// - Parameter size: The size of the mini-map
  public init(size: CGSize) {
    self.mapSize = size
    self.defaultSize = size

    // Background
    background = SKShapeNode(rect: CGRect(origin: .zero, size: size))
    background.fillColor = backgroundColor
    background.strokeColor = backgroundStrokeColor
    background.lineWidth = backgroundLineWidth
    background.alpha = backgroundAlpha

    // Base marker (optional)
    if showBaseMarker {
      baseMarker = SKShapeNode(circleOfRadius: 3)
      baseMarker?.fillColor = .blue
      baseMarker?.strokeColor = .white
      baseMarker?.lineWidth = 1
    } else {
      baseMarker = nil
    }

    // Camera view frame (initially hidden)
    cameraViewFrame = SKShapeNode()
    cameraViewFrame?.strokeColor = cameraFrameColor
    cameraViewFrame?.lineWidth = cameraFrameLineWidth
    cameraViewFrame?.alpha = cameraFrameAlpha

    super.init()

    // Set high zPosition to appear above other elements
    self.zPosition = miniMapZPosition

    addChild(background)
    if let baseMarker = baseMarker {
      addChild(baseMarker)
    }
    if let cameraFrame = cameraViewFrame {
      addChild(cameraFrame)
    }

    // Add drag and resize handles
    setupDragAndResizeHandles()
  }

  /// Initialize a mini-map with predefined size and location
  /// - Parameters:
  ///   - size: The size of the mini-map (predefined or custom)
  ///   - location: The location on screen where the mini-map should be positioned
  ///   - sceneSize: The size of the game scene
  ///   - margin: The margin from the screen edges (default: 20)
  public convenience init(
    size: MiniMapSize, location: MiniMapLocation, in sceneSize: CGSize, margin: CGFloat = 20
  ) {
    let mapSize = size.size
    self.init(size: mapSize)
    let defaultPos = location.position(in: sceneSize, mapSize: mapSize, margin: margin)
    self.position = defaultPos
    self.defaultPosition = defaultPos
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Click Handling

  /// Handle a click on the mini-map
  /// - Parameter location: The location of the click in mini-map coordinates
  public func handleClick(at location: CGPoint) {
    // Convert click location to scene coordinates
    let scenePosition = convertFromMapPosition(location)
    
    // Only call delegate if position updates on click are enabled
      delegate?.miniMapClicked(at: scenePosition)
    
      }
  
  // MARK: - Easy Integration Methods
  
  /// Handle mouse down event from scene (convenience method)
  /// - Parameters:
  ///   - location: Mouse location in scene coordinates
  ///   - scene: The parent scene
  /// - Returns: True if the event was handled by the mini-map
  public func handleMouseDown(at location: CGPoint, in scene: SKScene) -> Bool {
    let locationInMiniMap = convert(location, from: scene)
    if contains(locationInMiniMap) {
      // Check if mouse is over resize area (bottom-right corner)
      if isOverResizeArea(locationInMiniMap) {
        startResizing(at: locationInMiniMap)
        return true
      }
      // Check if mouse is over drag area (top-left corner)
      if isOverDragArea(locationInMiniMap) {
        startDragging(at: locationInMiniMap)
        return true
      }
      // Mouse is over mini-map but not over resize/drag areas
      // Don't handle click here - wait for mouse up
      return true
    }
    return false
  }
  
  /// Handle mouse dragged event from scene (convenience method)
  /// - Parameters:
  ///   - location: Mouse location in scene coordinates
  ///   - scene: The parent scene
  /// - Returns: True if the event was handled by the mini-map
  public func handleMouseDragged(to location: CGPoint, in scene: SKScene) -> Bool {
    // If we're already dragging or resizing, continue regardless of mouse position
    if isDragging || isResizing {
      let locationInMiniMap = convert(location, from: scene)
      handleTouchMoved(to: locationInMiniMap)
      return true
    }
    
    // If not dragging/resizing, only handle if mouse is over mini-map
    let locationInMiniMap = convert(location, from: scene)
    if contains(locationInMiniMap) {
      handleTouchMoved(to: locationInMiniMap)
      return true
    }
    return false
  }
  
  /// Handle mouse up event from scene (convenience method)
  /// - Parameters:
  ///   - location: Mouse location in scene coordinates
  ///   - scene: The parent scene
  /// - Returns: True if the event was handled by the mini-map
  public func handleMouseUp(at location: CGPoint, in scene: SKScene) -> Bool {
    // Always handle mouse up if we were dragging or resizing
    if isDragging || isResizing {
      handleTouchEnded()
      return true
    }
    
    // If not dragging/resizing, only handle if mouse is over mini-map
    let locationInMiniMap = convert(location, from: scene)
    if contains(locationInMiniMap) {
      // If we weren't dragging or resizing, it was a click
      if !isDragging && !isResizing {
        handleClick(at: locationInMiniMap)
      }
      
      handleTouchEnded()
      return true
    }
    return false
  }
  
  /// Handle right mouse down event from scene (convenience method)
  /// - Parameters:
  ///   - location: Mouse location in scene coordinates
  ///   - scene: The parent scene
  /// - Returns: True if the event was handled by the mini-map
  public func handleRightMouseDown(at location: CGPoint, in scene: SKScene) -> Bool {
    let locationInMiniMap = convert(location, from: scene)
    if contains(locationInMiniMap) {
      handleRightClick(at: locationInMiniMap)
      return true
    }
    return false
  }
  
  /// Handle mouse moved event from scene (convenience method)
  /// - Parameters:
  ///   - location: Mouse location in scene coordinates
  ///   - scene: The parent scene
  /// - Returns: True if the event was handled by the mini-map
  public func handleMouseMoved(to location: CGPoint, in scene: SKScene) -> Bool {
    let locationInMiniMap = convert(location, from: scene)
    if contains(locationInMiniMap) {
      // If currently dragging or resizing, maintain the appropriate cursor
      if isDragging {
        #if os(macOS)
        NSCursor.closedHand.set()
        #endif
        return true
      }
      if isResizing {
        #if os(macOS)
        NSCursor.crosshair.set()
        #endif
        return true
      }
      
      // Not dragging or resizing, so check hover areas
      // Check if mouse is over resize area (bottom-right corner)
      if isOverResizeArea(locationInMiniMap) {
        #if os(macOS)
        NSCursor.crosshair.set()
        #endif
        return true
      }
      // Check if mouse is over drag area (top-left corner)
      if isOverDragArea(locationInMiniMap) {
        #if os(macOS)
        NSCursor.openHand.set()
        #endif
        return true
      }
      // Mouse is over mini-map but not over resize/drag areas
      #if os(macOS)
      NSCursor.arrow.set()
      #endif
      return true
    }
    return false
  }

  // MARK: - Bounds Checking

  /// Check if a point is within the mini-map bounds
  /// - Parameter point: The point to check
  /// - Returns: True if the point is within the mini-map bounds
  public override func contains(_ point: CGPoint) -> Bool {
    return background.contains(point)
  }

  // MARK: - Position Updates

  /// Update the position of the base marker on the mini-map
  /// - Parameters:
  ///   - position: The position of the base in scene coordinates
  ///   - sceneSize: The size of the game scene
  public func updateBasePosition(_ position: CGPoint, sceneSize: CGSize) {
    guard let baseMarker = baseMarker else { return }
    let mapPosition = convertToMapPosition(position, sceneSize: sceneSize)
    baseMarker.position = mapPosition
  }

  /// Update the positions of all entities on the mini-map
  /// - Parameters:
  ///   - entities: Array of entities to display on the mini-map
  ///   - sceneSize: The size of the game scene
  public func updateEntityPositions(_ entities: [AnyMiniMapEntity], sceneSize: CGSize) {
    // Store current entities and scene size for resize updates
    currentEntities = entities
    currentSceneSize = sceneSize
    
    // Remove old markers
    for marker in entityMarkers {
      marker.removeFromParent()
    }
    entityMarkers.removeAll()

    // Add new markers
    for entity in entities {
      let marker = SKShapeNode(circleOfRadius: entity.markerRadius)
      marker.fillColor = entity.markerColor
      marker.strokeColor = entity.markerStrokeColor
      marker.lineWidth = entity.markerLineWidth

      let mapPosition = convertToMapPosition(entity.position, sceneSize: sceneSize)
      marker.position = mapPosition
      entityMarkers.append(marker)
      addChild(marker)
    }
  }

  /// Update the camera view frame on the mini-map
  /// - Parameters:
  ///   - cameraPosition: The position of the camera in scene coordinates
  ///   - cameraZoom: The zoom level of the camera
  ///   - sceneSize: The size of the game scene
  public func updateCameraViewFrame(cameraPosition: CGPoint, cameraZoom: CGFloat, sceneSize: CGSize)
  {
    guard let cameraFrame = cameraViewFrame else { return }

    // Calculate the visible area of the camera
    // When zoomed in (cameraZoom is small), viewport gets smaller
    // When zoomed out (cameraZoom is large), viewport gets larger
    let viewportWidth = sceneSize.width * cameraZoom
    let viewportHeight = sceneSize.height * cameraZoom

    // Calculate the corners of the camera view
    let topLeft = CGPoint(
      x: cameraPosition.x - viewportWidth / 2, y: cameraPosition.y + viewportHeight / 2)
    let topRight = CGPoint(
      x: cameraPosition.x + viewportWidth / 2, y: cameraPosition.y + viewportHeight / 2)
    let bottomLeft = CGPoint(
      x: cameraPosition.x - viewportWidth / 2, y: cameraPosition.y - viewportHeight / 2)
    let bottomRight = CGPoint(
      x: cameraPosition.x + viewportWidth / 2, y: cameraPosition.y - viewportHeight / 2)

    // Convert to map coordinates
    let mapTopLeft = convertToMapPosition(topLeft, sceneSize: sceneSize)
    let mapTopRight = convertToMapPosition(topRight, sceneSize: sceneSize)
    let mapBottomLeft = convertToMapPosition(bottomLeft, sceneSize: sceneSize)
    let mapBottomRight = convertToMapPosition(bottomRight, sceneSize: sceneSize)

    // Clamp coordinates to stay within mini-map bounds
    let clampedTopLeft = CGPoint(
      x: max(0, min(mapSize.width, mapTopLeft.x)),
      y: max(0, min(mapSize.height, mapTopLeft.y)))
    let clampedTopRight = CGPoint(
      x: max(0, min(mapSize.width, mapTopRight.x)),
      y: max(0, min(mapSize.height, mapTopRight.y)))
    let clampedBottomLeft = CGPoint(
      x: max(0, min(mapSize.width, mapBottomLeft.x)),
      y: max(0, min(mapSize.height, mapBottomLeft.y)))
    let clampedBottomRight = CGPoint(
      x: max(0, min(mapSize.width, mapBottomRight.x)),
      y: max(0, min(mapSize.height, mapBottomRight.y)))

    // Create the camera view frame path
    let path = CGMutablePath()
    path.move(to: clampedTopLeft)
    path.addLine(to: clampedTopRight)
    path.addLine(to: clampedBottomRight)
    path.addLine(to: clampedBottomLeft)
    path.closeSubpath()

    cameraFrame.path = path
  }

  // MARK: - Coordinate Conversion

  private func convertToMapPosition(_ scenePosition: CGPoint, sceneSize: CGSize) -> CGPoint {
    let scaleX = mapSize.width / sceneSize.width
    let scaleY = mapSize.height / sceneSize.height
    return CGPoint(x: scenePosition.x * scaleX, y: scenePosition.y * scaleY)
  }

  private func convertFromMapPosition(_ mapPosition: CGPoint) -> CGPoint {
    // Get the scene size from the parent scene
    guard let scene = self.scene else { return .zero }
    let sceneSize = scene.size

    let scaleX = sceneSize.width / mapSize.width
    let scaleY = sceneSize.height / mapSize.height
    return CGPoint(x: mapPosition.x * scaleX, y: mapPosition.y * scaleY)
  }

  // MARK: - Dragging and Resizing

  private func setupDragAndResizeHandles() {
    // No visual handles needed for standard window resizing
    // The resize and drag areas are defined by the isOverResizeArea and isOverDragArea methods
  }

  public func handleTouch(at location: CGPoint) {
    // Check for stuck operations first
    checkForStuckResize()
    checkForStuckDrag()

    // Check if touch is on drag area (top-left corner)
    if isOverDragArea(location) {
      startDragging(at: location)
      return
    }

    // Check if touch is on resize area (bottom-right corner)
    if isOverResizeArea(location) {
      startResizing(at: location)
      return
    }

    // Check if touch is on background (for dragging)
//    if background.contains(location) {
//      startDragging(at: location)
//      return
//    }

    // Otherwise, handle as click
    handleClick(at: location)
  }

  public func handleRightClick(at location: CGPoint) {
    // Reset to default position and size
    resetToDefault()
  }

  // MARK: - Standard Window Resizing

  public func isOverResizeArea(_ location: CGPoint) -> Bool {
    // Check if mouse is in the bottom-right corner area for resizing
    let resizeAreaSize: CGFloat = 25
    // For macOS, the Y coordinates might be inverted, so we check the top-right corner instead
    #if os(macOS)
      return location.x >= mapSize.width - resizeAreaSize
        && location.y <= resizeAreaSize
    #else
      return location.x >= mapSize.width - resizeAreaSize
        && location.y >= mapSize.height - resizeAreaSize
    #endif
  }

  public func isOverDragArea(_ location: CGPoint) -> Bool {
    // Check if mouse is in the top area for dragging (entire top edge)
    let dragAreaHeight: CGFloat = 25
    // For macOS, the Y coordinates might be inverted, so we check the bottom area instead
    #if os(macOS)
      return location.y >= mapSize.height - dragAreaHeight
    #else
      return location.y <= dragAreaHeight
    #endif
  }

  public func handleTouchMoved(to location: CGPoint) {
    if isDragging {
      updateDragging(to: location)
    } else if isResizing {
      updateResizing(to: location)
    }
  }

  public func handleTouchEnded() {
    if isDragging {
      endDragging()
    } else if isResizing {
      endResizing()
    }
  }

  private func startDragging(at location: CGPoint) {
    isDragging = true
    dragStart = location
    
    // Calculate the offset from the mini-map's position to the drag start point
    // location is in scene coordinates, position is in scene coordinates
    dragOffset = CGPoint(x: location.x - position.x, y: location.y - position.y)
  }

  private func updateDragging(to location: CGPoint) {
    // Update the last drag time
    lastDragTime = CACurrentMediaTime()

    // Calculate the new position by subtracting the offset from the mouse location
    // Both location and dragOffset are in scene coordinates
    let newPosition = CGPoint(x: location.x - dragOffset.x, y: location.y - dragOffset.y)
    
    // Update the mini-map position
    position = newPosition
  }

  private func endDragging() {
    isDragging = false
    // Reset drag state to prevent getting stuck
    dragStart = .zero
    lastDragTime = 0
  }

  private func startResizing(at location: CGPoint) {
    isResizing = true
    resizeStart = location
    originalSize = mapSize
  }

  private func updateResizing(to location: CGPoint) {
    // Update the last resize time
    lastResizeTime = CACurrentMediaTime()

    // Calculate the total delta from the original resize start position
    let totalDelta = CGPoint(x: location.x - resizeStart.x, y: location.y - resizeStart.y)

    // Calculate new size based on the original size plus the total delta
    let newWidth = max(100, originalSize.width + totalDelta.x)
    let newHeight = max(100, originalSize.height + totalDelta.y)

    // Update the map size
    mapSize = CGSize(width: newWidth, height: newHeight)
    updateMapSize()
  }

  private func endResizing() {
    isResizing = false
    // Reset resize state to prevent getting stuck
    resizeStart = .zero
    originalSize = .zero
    lastResizeTime = 0
  }

  // Check if resize operation is stuck and reset if necessary
  private func checkForStuckResize() {
    if isResizing && CACurrentMediaTime() - lastResizeTime > resizeTimeout {
      // Reset stuck resize operation
      isResizing = false
      resizeStart = .zero
      originalSize = .zero
      lastResizeTime = 0
    }
  }

  // Check if drag operation is stuck and reset if necessary
  private func checkForStuckDrag() {
    if isDragging && CACurrentMediaTime() - lastDragTime > dragTimeout {
      // Reset stuck drag operation
      isDragging = false
      dragStart = .zero
      lastDragTime = 0
    }
  }

  private func updateMapSize() {
    // Update background size
    background.path = CGPath(rect: CGRect(origin: .zero, size: mapSize), transform: nil)

    // Recalculate entity positions for the new map size
    if !currentEntities.isEmpty {
      updateEntityPositions(currentEntities, sceneSize: currentSceneSize)
    }
  }

  private func resetToDefault() {
    // Reset position
    position = defaultPosition

    // Reset size
    mapSize = defaultSize

    // Update visual elements
    updateMapSize()
  }
}
