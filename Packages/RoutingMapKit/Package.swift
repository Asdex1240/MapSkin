// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RoutingMapKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RoutingMapKit", targets: ["RoutingMapKit"])
    ],
    dependencies: [
        .package(path: "../NavigationCore")
    ],
    targets: [
        .target(
            name: "RoutingMapKit",
            dependencies: ["NavigationCore"]
        )
    ]
)
