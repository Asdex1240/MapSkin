// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PlaceSearch",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "PlaceSearch", targets: ["PlaceSearch"])
    ],
    dependencies: [
        .package(path: "../NavigationCore")
    ],
    targets: [
        .target(
            name: "PlaceSearch",
            dependencies: ["NavigationCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PlaceSearchTests",
            dependencies: ["PlaceSearch"]
        )
    ]
)
