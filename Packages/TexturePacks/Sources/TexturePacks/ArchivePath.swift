enum ArchivePath {
    private static let acceptedExtensions: Set<String> = ["png", "jpg", "jpeg", "json"]
    private static let ignoredComponents: Set<String> = ["__MACOSX", ".DS_Store"]

    static func components(of rawPath: String) throws -> [String] {
        let normalized = rawPath.replacingOccurrences(of: "\\", with: "/")
        guard !normalized.hasPrefix("/"), !normalized.contains(":") else { throw TexturePackImportError.unsafePath }
        let components = normalized.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        guard !components.contains(".."), !components.contains(".") else { throw TexturePackImportError.unsafePath }
        return components
    }

    static func isIgnored(_ components: [String]) -> Bool {
        components.contains { ignoredComponents.contains($0) || $0.hasPrefix("._") }
    }

    static func isAccepted(_ components: [String]) -> Bool {
        guard let fileName = components.last, let dot = fileName.lastIndex(of: ".") else { return false }
        return acceptedExtensions.contains(fileName[fileName.index(after: dot)...].lowercased())
    }
}
