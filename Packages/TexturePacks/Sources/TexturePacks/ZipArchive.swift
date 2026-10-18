import Compression
import Foundation

struct ZipArchive {
    private enum Signature {
        static let endOfCentralDirectory: UInt32 = 0x0605_4B50
        static let centralDirectoryEntry: UInt32 = 0x0201_4B50
        static let localFileHeader: UInt32 = 0x0403_4B50
    }

    private static let endOfCentralDirectoryLength = 22
    private static let maximumCommentLength = 0xFFFF
    private static let encryptedFlag: UInt16 = 1
    private static let zip64Marker: UInt32 = 0xFFFF_FFFF

    let entries: [ZipEntry]
    private let data: Data

    init(data: Data) throws {
        self.data = data
        entries = try Self.readEntries(in: data)
    }

    func contents(of entry: ZipEntry) throws -> Data {
        let reader = ByteReader(data: data)
        guard try reader.uint32(at: entry.localHeaderOffset) == Signature.localFileHeader else {
            throw TexturePackImportError.unreadableArchive
        }
        let nameLength = Int(try reader.uint16(at: entry.localHeaderOffset + 26))
        let extraLength = Int(try reader.uint16(at: entry.localHeaderOffset + 28))
        let start = entry.localHeaderOffset + 30 + nameLength + extraLength
        let compressed = try reader.bytes(at: start, count: entry.compressedSize)
        let contents = try decompress(compressed, entry: entry)
        guard CRC32.checksum(of: contents) == entry.checksum else {
            throw TexturePackImportError.unreadableArchive
        }
        return contents
    }

    private func decompress(_ compressed: Data, entry: ZipEntry) throws -> Data {
        switch entry.method {
        case .stored:
            guard compressed.count == entry.uncompressedSize else { throw TexturePackImportError.unreadableArchive }
            return compressed
        case .deflated:
            return try Self.inflate(compressed, expectedSize: entry.uncompressedSize)
        }
    }

    private static func inflate(_ compressed: Data, expectedSize: Int) throws -> Data {
        guard expectedSize > 0 else { return Data() }
        var output = Data(count: expectedSize)
        let decodedSize = output.withUnsafeMutableBytes { destination in
            compressed.withUnsafeBytes { source in
                guard
                    let destinationAddress = destination.bindMemory(to: UInt8.self).baseAddress,
                    let sourceAddress = source.bindMemory(to: UInt8.self).baseAddress
                else { return 0 }
                return compression_decode_buffer(
                    destinationAddress, expectedSize, sourceAddress, compressed.count, nil, COMPRESSION_ZLIB
                )
            }
        }
        guard decodedSize == expectedSize else { throw TexturePackImportError.unreadableArchive }
        return output
    }

    private static func readEntries(in data: Data) throws -> [ZipEntry] {
        let reader = ByteReader(data: data)
        let endRecord = try endOfCentralDirectoryOffset(in: data)
        let entryCount = Int(try reader.uint16(at: endRecord + 10))
        var offset = Int(try reader.uint32(at: endRecord + 16))
        var entries: [ZipEntry] = []
        for _ in 0..<entryCount {
            let (entry, nextOffset) = try centralDirectoryEntry(at: offset, reader: reader)
            entries.append(entry)
            offset = nextOffset
        }
        return entries
    }

    private static func endOfCentralDirectoryOffset(in data: Data) throws -> Int {
        let reader = ByteReader(data: data)
        let lastCandidate = data.count - endOfCentralDirectoryLength
        guard lastCandidate >= 0 else { throw TexturePackImportError.unreadableArchive }
        let firstCandidate = max(0, lastCandidate - maximumCommentLength)
        for offset in stride(from: lastCandidate, through: firstCandidate, by: -1)
        where try reader.uint32(at: offset) == Signature.endOfCentralDirectory {
            return offset
        }
        throw TexturePackImportError.unreadableArchive
    }

    private static func centralDirectoryEntry(at offset: Int, reader: ByteReader) throws -> (ZipEntry, Int) {
        guard try reader.uint32(at: offset) == Signature.centralDirectoryEntry else {
            throw TexturePackImportError.unreadableArchive
        }
        let flags = try reader.uint16(at: offset + 8)
        let compressedSize = try reader.uint32(at: offset + 20)
        let uncompressedSize = try reader.uint32(at: offset + 24)
        let localHeaderOffset = try reader.uint32(at: offset + 42)
        guard
            flags & encryptedFlag == 0,
            ![compressedSize, uncompressedSize, localHeaderOffset].contains(zip64Marker)
        else { throw TexturePackImportError.unreadableArchive }

        let nameLength = Int(try reader.uint16(at: offset + 28))
        let extraLength = Int(try reader.uint16(at: offset + 30))
        let commentLength = Int(try reader.uint16(at: offset + 32))
        let nameData = try reader.bytes(at: offset + 46, count: nameLength)
        let entry = ZipEntry(
            path: String(decoding: nameData, as: UTF8.self),
            method: try method(code: reader.uint16(at: offset + 10)),
            checksum: try reader.uint32(at: offset + 16),
            compressedSize: Int(compressedSize),
            uncompressedSize: Int(uncompressedSize),
            localHeaderOffset: Int(localHeaderOffset)
        )
        return (entry, offset + 46 + nameLength + extraLength + commentLength)
    }

    private static func method(code: UInt16) throws -> ZipEntry.Method {
        switch code {
        case 0: .stored
        case 8: .deflated
        default: throw TexturePackImportError.unreadableArchive
        }
    }
}

private struct ByteReader {
    let data: Data

    func uint16(at offset: Int) throws -> UInt16 {
        let bytes = try self.bytes(at: offset, count: 2)
        return UInt16(bytes[bytes.startIndex]) | UInt16(bytes[bytes.startIndex + 1]) << 8
    }

    func uint32(at offset: Int) throws -> UInt32 {
        let bytes = try self.bytes(at: offset, count: 4)
        return (0..<4).reduce(UInt32(0)) { value, index in
            value | UInt32(bytes[bytes.startIndex + index]) << (8 * UInt32(index))
        }
    }

    func bytes(at offset: Int, count: Int) throws -> Data {
        guard offset >= 0, count >= 0, offset + count <= data.count else {
            throw TexturePackImportError.unreadableArchive
        }
        let start = data.startIndex + offset
        return data[start..<(start + count)]
    }
}
