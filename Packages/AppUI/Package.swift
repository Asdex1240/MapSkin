// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppUI", targets: ["AppUI"])
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
            name: "AppUI",
            dependencies: ["MapRendering", "MapStyle", "NavigationCore", "PlaceSearch", "TexturePacks"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AppUITests",
            dependencies: ["AppUI"]
        )
    ]
)
