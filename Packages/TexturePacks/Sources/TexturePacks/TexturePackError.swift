import Foundation

public enum TexturePackError: Error, Equatable {
    case manifestNotFound
    case invalidManifest
    case textureNotFound(TextureKind)
    case unreadableTexture(TextureKind)
}

extension TexturePackError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .manifestNotFound:
            String(localized: "texturePacks.error.manifestNotFound", bundle: .module)
        case .invalidManifest:
            String(localized: "texturePacks.error.invalidManifest", bundle: .module)
        case .textureNotFound(let kind):
            String(localized: "texturePacks.error.textureNotFound \(kind.rawValue)", bundle: .module)
        case .unreadableTexture(let kind):
            String(localized: "texturePacks.error.unreadableTexture \(kind.rawValue)", bundle: .module)
        }
    }
}
