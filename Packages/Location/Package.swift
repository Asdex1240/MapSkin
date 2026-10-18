// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Location",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Location", targets: ["Location"])
    ],
    dependencies: [
        .package(path: "../NavigationCore")
    ],
    targets: [
        .target(
            name: "Location",
            dependencies: ["NavigationCore"]
        ),
        .testTarget(
            name: "LocationTests",
            dependencies: ["Location"]
        )
    ]
)
