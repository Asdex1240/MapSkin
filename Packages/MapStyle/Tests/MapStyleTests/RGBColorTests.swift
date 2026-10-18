import MapStyle
import Testing

struct RGBColorTests {
    @Test(arguments: ["#1A73E8", "1A73E8", "#1a73e8"])
    func parsesHexColor(hex: String) throws {
        let color = try #require(RGBColor(hex: hex))

        #expect(color.hexString == "#1A73E8")
    }

    @Test(arguments: ["", "#FFF", "#GGGGGG", "#1A73E8FF", "+1A73E8", "red"])
    func rejectsInvalidHex(hex: String) {
        #expect(RGBColor(hex: hex) == nil)
    }

    @Test func blackAndWhiteHaveMaximumContrast() {
        #expect(abs(RGBColor.black.contrastRatio(with: .white) - 21) < 0.01)
    }

    @Test func contrastIsSymmetric() throws {
        let blue = try #require(RGBColor(hex: "#1A73E8"))
        let beige = try #require(RGBColor(hex: "#EDEAE2"))

        #expect(blue.contrastRatio(with: beige) == beige.contrastRatio(with: blue))
    }

    @Test func mixesHalfway() {
        let gray = RGBColor.black.mixed(with: .white, amount: 0.5)

        #expect(gray.hexString == "#808080")
    }
}
