import Foundation
@testable import TexturePacks

struct TestZipBuilder {
    private var entries: [(path: String, data: Data)] = []

    mutating func add(_ path: String, data: Data) {
        entries.append((path, data))
    }

    func build() -> Data {
        var archive = Data()
        var centralDirectory = Data()
        for entry in entries {
            let nameData = Data(entry.path.utf8)
            let checksum = CRC32.checksum(of: entry.data)
            let offset = UInt32(archive.count)
            archive.append(littleEndian: UInt32(0x0403_4B50))
            archive.append(littleEndian: UInt16(20))
            archive.append(littleEndian: UInt16(0))
            archive.append(littleEndian: UInt16(0))
            archive.append(littleEndian: UInt32(0))
            archive.append(littleEndian: checksum)
            archive.append(littleEndian: UInt32(entry.data.count))
            archive.append(littleEndian: UInt32(entry.data.count))
            archive.append(littleEndian: UInt16(nameData.count))
            archive.append(littleEndian: UInt16(0))
            archive.append(nameData)
            archive.append(entry.data)

            centralDirectory.append(littleEndian: UInt32(0x0201_4B50))
            centralDirectory.append(littleEndian: UInt16(20))
            centralDirectory.append(littleEndian: UInt16(20))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt32(0))
            centralDirectory.append(littleEndian: checksum)
            centralDirectory.append(littleEndian: UInt32(entry.data.count))
            centralDirectory.append(littleEndian: UInt32(entry.data.count))
            centralDirectory.append(littleEndian: UInt16(nameData.count))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt16(0))
            centralDirectory.append(littleEndian: UInt32(0))
            centralDirectory.append(littleEndian: offset)
            centralDirectory.append(nameData)
        }
        let centralDirectoryOffset = UInt32(archive.count)
        archive.append(centralDirectory)
        archive.append(littleEndian: UInt32(0x0605_4B50))
        archive.append(littleEndian: UInt16(0))
        archive.append(littleEndian: UInt16(0))
        archive.append(littleEndian: UInt16(entries.count))
        archive.append(littleEndian: UInt16(entries.count))
        archive.append(littleEndian: UInt32(centralDirectory.count))
        archive.append(littleEndian: centralDirectoryOffset)
        archive.append(littleEndian: UInt16(0))
        return archive
    }

    func write(to url: URL) throws {
        try build().write(to: url)
    }
}

extension Data {
    mutating func append<Value: FixedWidthInteger>(littleEndian value: Value) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }
}
