// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MapStyle",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "MapStyle", targets: ["MapStyle"])
    ],
    dependencies: [
        .package(path: "../TexturePacks")
    ],
    targets: [
        .target(
            name: "MapStyle",
            dependencies: ["TexturePacks"]
        ),
        .testTarget(
            name: "MapStyleTests",
            dependencies: ["MapStyle"]
        )
    ]
)
