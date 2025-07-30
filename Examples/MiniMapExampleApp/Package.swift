// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "MiniMapExampleApp",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(
      name: "MiniMapExampleApp",
      targets: ["MiniMapExampleApp"])
  ],
  dependencies: [
    .package(path: "../../")
  ],
  targets: [
    .executableTarget(
      name: "MiniMapExampleApp",
      dependencies: ["MiniMapPackage"])
  ]
)
