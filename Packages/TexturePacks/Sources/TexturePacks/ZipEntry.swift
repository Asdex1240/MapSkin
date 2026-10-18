struct ZipEntry: Equatable {
    enum Method: Equatable {
        case stored
        case deflated
    }

    let path: String
    let method: Method
    let checksum: UInt32
    let compressedSize: Int
    let uncompressedSize: Int
    let localHeaderOffset: Int

    var isDirectory: Bool {
        path.hasSuffix("/")
    }
}
