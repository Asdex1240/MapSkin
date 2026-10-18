import CoreGraphics

enum PixelArtScaler {
    static func upscale(_ image: CGImage, by factor: Int) -> CGImage? {
        guard factor > 1 else { return image }
        let width = image.width * factor
        let height = image.height * factor
        guard let context = RGBABitmap.makeContext(width: width, height: height) else { return nil }
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}
