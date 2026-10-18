// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TexturePacks",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TexturePacks", targets: ["TexturePacks"])
    ],
    targets: [
        .target(
            name: "TexturePacks",
            resources: [.copy("BundledPacks")]
        ),
        .testTarget(
            name: "TexturePacksTests",
            dependencies: ["TexturePacks"],
            resources: [.copy("Fixtures")]
        )
    ]
)
