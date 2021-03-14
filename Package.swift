// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResponsiveTextField",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ResponsiveTextField",
            targets: ["ResponsiveTextField"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.1")
    ],
    targets: [
        .target(
            name: "ResponsiveTextField",
            dependencies: []),
        .testTarget(
            name: "ResponsiveTextFieldTests",
            dependencies: ["ResponsiveTextField", "SnapshotTesting"],
            exclude: ["__Snapshots__"]),
    ]
)
