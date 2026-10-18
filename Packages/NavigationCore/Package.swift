// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NavigationCore",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "NavigationCore", targets: ["NavigationCore"])
    ],
    targets: [
        .target(
            name: "NavigationCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NavigationCoreTests",
            dependencies: ["NavigationCore"]
        )
    ]
)
