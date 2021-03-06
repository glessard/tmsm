// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "tmsm",
  platforms: [
    .macOS(.v10_15),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.2")),
    .package(url: "https://github.com/apple/swift-algorithms", .branch("main")),
    // .package(url: "https://github.com/apple/swift-system", .upToNextMinor(from: "0.0.1")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "tmsm",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]),
    .testTarget(
      name: "tmsmTests",
      dependencies: ["tmsm"]),
  ]
)
