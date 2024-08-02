// swift-tools-version:5.9
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
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.2"),
        .package(name: "combine-schedulers", url: "https://github.com/pointfreeco/combine-schedulers.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "ResponsiveTextField",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("InferSendableFromCaptures")
            ]
        ),
        .testTarget(
            name: "ResponsiveTextFieldTests",
            dependencies: ["ResponsiveTextField", "SnapshotTesting"],
            exclude: ["__Snapshots__"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("InferSendableFromCaptures")
            ]
        )
    ]
)
