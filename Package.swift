// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Toast",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Toast",
            targets: ["Toast"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Toast",
            dependencies: [])
    ]
)
