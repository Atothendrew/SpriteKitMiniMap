// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MiniMapPackage",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "MiniMapPackage",
      targets: ["MiniMapPackage"])
  ],
  dependencies: [
    // No external dependencies required
  ],
  targets: [
    .target(
      name: "MiniMapPackage",
      dependencies: []),
    .testTarget(
      name: "MiniMapPackageTests",
      dependencies: ["MiniMapPackage"]),
  ]
)
