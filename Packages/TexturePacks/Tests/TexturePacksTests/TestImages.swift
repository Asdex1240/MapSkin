import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

struct RGBAPixel: Equatable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var luminance: Double {
        0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue)
    }
}

enum TestImages {
    static func make(rows: [[RGBAPixel]]) throws -> CGImage {
        let height = rows.count
        let width = try #require(rows.first).count
        var bytes = rows.flatMap { $0 }.flatMap { [$0.red, $0.green, $0.blue, $0.alpha] }
        let context = try #require(
            CGContext(
                data: &bytes,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        return try #require(context.makeImage())
    }

    static func solid(_ pixel: RGBAPixel, size: Int) throws -> CGImage {
        try make(rows: Array(repeating: Array(repeating: pixel, count: size), count: size))
    }

    static func pixel(of image: CGImage, x: Int, y: Int) throws -> RGBAPixel {
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = try #require(
            CGContext(
                data: &bytes,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let offset = (y * image.width + x) * 4
        return RGBAPixel(
            red: bytes[offset],
            green: bytes[offset + 1],
            blue: bytes[offset + 2],
            alpha: bytes[offset + 3]
        )
    }

    static func writePNG(_ image: CGImage, to url: URL) throws {
        let destination = try #require(
            CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
    }
}
