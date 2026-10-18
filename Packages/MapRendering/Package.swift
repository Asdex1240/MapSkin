// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MapRendering",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MapRendering", targets: ["MapRendering"])
    ],
    dependencies: [
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", exact: "6.31.0")
    ],
    targets: [
        .target(
            name: "MapRendering",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution")
            ]
        )
    ]
)
