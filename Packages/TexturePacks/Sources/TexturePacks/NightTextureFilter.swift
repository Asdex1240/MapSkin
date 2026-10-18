import CoreGraphics

enum NightTextureFilter {
    private static let brightness = 0.6
    private static let saturation = 0.7
    private static let redTint = 0.92
    private static let greenTint = 0.96
    private static let blueTint = 1.08

    static func apply(to image: CGImage) -> CGImage? {
        guard
            let context = RGBABitmap.makeContext(drawing: image),
            let data = context.data
        else { return nil }

        let byteCount = image.width * image.height * RGBABitmap.bytesPerPixel
        let pixels = data.bindMemory(to: UInt8.self, capacity: byteCount)
        for offset in stride(from: 0, to: byteCount, by: RGBABitmap.bytesPerPixel) {
            let red = Double(pixels[offset])
            let green = Double(pixels[offset + 1])
            let blue = Double(pixels[offset + 2])
            let gray = 0.299 * red + 0.587 * green + 0.114 * blue
            pixels[offset] = adjusted(red, gray: gray, tint: redTint)
            pixels[offset + 1] = adjusted(green, gray: gray, tint: greenTint)
            pixels[offset + 2] = adjusted(blue, gray: gray, tint: blueTint)
        }
        return context.makeImage()
    }

    private static func adjusted(_ channel: Double, gray: Double, tint: Double) -> UInt8 {
        let desaturated = gray + (channel - gray) * saturation
        let value = desaturated * brightness * tint
        return UInt8(min(255, max(0, value)).rounded())
    }
}
