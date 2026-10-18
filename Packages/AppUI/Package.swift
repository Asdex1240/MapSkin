// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppUI", targets: ["AppUI"])
    ],
    dependencies: [
        .package(path: "../MapRendering")
    ],
    targets: [
        .target(
            name: "AppUI",
            dependencies: ["MapRendering"]
        )
    ]
)
