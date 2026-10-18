import Testing
@testable import TexturePacks

struct ArchivePathTests {
    @Test(arguments: [
        "../evil.png", "day/../../evil.png", "/etc/evil.png", "..\\evil.png", "C:\\evil.png", "./pack.json"
    ])
    func rejectsUnsafePaths(path: String) {
        #expect(throws: TexturePackImportError.unsafePath) {
            try ArchivePath.components(of: path)
        }
    }

    @Test func splitsSafePaths() throws {
        #expect(try ArchivePath.components(of: "day/grass.png") == ["day", "grass.png"])
        #expect(try ArchivePath.components(of: "folder\\night\\water.jpg") == ["folder", "night", "water.jpg"])
    }

    @Test(arguments: [["__MACOSX", "day", "grass.png"], ["day", ".DS_Store"], ["day", "._grass.png"]])
    func ignoresSystemFiles(components: [String]) {
        #expect(ArchivePath.isIgnored(components))
    }

    @Test(arguments: [(["pack.json"], true), (["day", "grass.PNG"], true), (["day", "rock.jpeg"], true),
                      (["run.sh"], false), (["day", "grass.gif"], false), (["README"], false)])
    func acceptsOnlyImagesAndJSON(components: [String], isAccepted: Bool) {
        #expect(ArchivePath.isAccepted(components) == isAccepted)
    }
}
