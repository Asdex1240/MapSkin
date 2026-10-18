// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CarPlayUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CarPlayUI", targets: ["CarPlayUI"])
    ],
    dependencies: [
        .package(path: "../MapRendering"),
        .package(path: "../MapStyle"),
        .package(path: "../NavigationCore"),
        .package(path: "../PlaceSearch"),
        .package(path: "../TexturePacks")
    ],
    targets: [
        .target(
            name: "CarPlayUI",
            dependencies: ["MapRendering", "MapStyle", "NavigationCore", "PlaceSearch", "TexturePacks"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CarPlayUITests",
            dependencies: ["CarPlayUI"]
        )
    ]
)
