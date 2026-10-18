import CoreGraphics

public struct TextureImage: Sendable {
    public let cgImage: CGImage
    public let scale: Double

    public init(cgImage: CGImage, scale: Double) {
        self.cgImage = cgImage
        self.scale = scale
    }
}
