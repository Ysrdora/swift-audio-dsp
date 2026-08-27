// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AudioDSP",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "AudioDSP",
            targets: ["AudioDSP"]
        )
    ],
    targets: [
        .target(
            name: "AudioDSP",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AudioDSPTests",
            dependencies: ["AudioDSP"]
        )
    ]
)
