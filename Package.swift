// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-effects",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .watchOS(.v6),
    .tvOS(.v13),
    .macCatalyst(.v13)
  ],
  products: [
    .library(
      name: "Effects",
      targets: ["Effects"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: Version(1, 0, 0))
  ],
  targets: [
    .target(
      name: "Effects",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "EffectsTests",
      dependencies: ["Effects"]
    ),
  ]
)
