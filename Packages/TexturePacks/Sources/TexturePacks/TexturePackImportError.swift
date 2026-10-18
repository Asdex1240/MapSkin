import Foundation

public enum TexturePackImportError: Error, Equatable {
    case unreadableArchive
    case unsafePath
    case tooManyFiles
    case tooLarge
    case manifestNotFound
    case invalidManifest
    case unsupportedFormatVersion(Int)
    case invalidImage(String)
    case imageNotSquare(String)
    case imageSizeOutOfRange(String)
    case noTextures
}

extension TexturePackImportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unreadableArchive:
            String(localized: "texturePacks.import.error.unreadableArchive", bundle: .module)
        case .unsafePath:
            String(localized: "texturePacks.import.error.unsafePath", bundle: .module)
        case .tooManyFiles:
            String(localized: "texturePacks.import.error.tooManyFiles \(Self.maximumFileCount)", bundle: .module)
        case .tooLarge:
            String(localized: "texturePacks.import.error.tooLarge \(Self.maximumMegabytes)", bundle: .module)
        case .manifestNotFound:
            String(localized: "texturePacks.import.error.manifestNotFound", bundle: .module)
        case .invalidManifest:
            String(localized: "texturePacks.import.error.invalidManifest", bundle: .module)
        case .unsupportedFormatVersion(let version):
            String(localized: "texturePacks.import.error.unsupportedFormatVersion \(version)", bundle: .module)
        case .invalidImage(let name):
            String(localized: "texturePacks.import.error.invalidImage \(name)", bundle: .module)
        case .imageNotSquare(let name):
            String(localized: "texturePacks.import.error.imageNotSquare \(name)", bundle: .module)
        case .imageSizeOutOfRange(let name):
            Self.sizeOutOfRangeDescription(for: name)
        case .noTextures:
            String(localized: "texturePacks.import.error.noTextures", bundle: .module)
        }
    }

    private static func sizeOutOfRangeDescription(for name: String) -> String {
        let minimum = minimumSide
        let maximum = maximumSide
        let key: String.LocalizationValue =
            "texturePacks.import.error.imageSizeOutOfRange \(name) \(minimum) \(maximum)"
        return String(localized: key, bundle: .module)
    }

    private static let maximumFileCount = TexturePackLimits.maximumFileCount
    private static let maximumMegabytes = TexturePackLimits.maximumTotalBytes / (1024 * 1024)
    private static let minimumSide = TexturePackLimits.imageSideRange.lowerBound
    private static let maximumSide = TexturePackLimits.imageSideRange.upperBound
}
