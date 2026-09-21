import AppKit
import XCTest
@testable import FigmaColorPicker

final class ColorComponentsTests: XCTestCase {
    func testPatternColorUsesFallbackAndSystemColorCanBeEdited() {
        let image = NSImage(size: NSSize(width: 2, height: 2))
        let fallback = ColorComponents(NSColor(patternImage: image))
        XCTAssertEqual(fallback.brightness, 0)
        XCTAssertEqual(fallback.alpha, 1)
        let systemColor = ColorComponents(.systemRed)
        XCTAssertGreaterThan(systemColor.red, systemColor.green)
    }

    func testGrayscaleIsConvertedBeforeReadingRGBComponents() {
        let components = ColorComponents(NSColor(deviceWhite: 0.4, alpha: 0.3))
        XCTAssertEqual(components.red, components.green, accuracy: 0.0001)
        XCTAssertEqual(components.green, components.blue, accuracy: 0.0001)
        XCTAssertEqual(components.alpha, 0.3, accuracy: 0.0001)
    }

    func testP3AndAlphaSurviveRGBEdits() {
        var components = ColorComponents(NSColor(displayP3Red: 0.8, green: 0.2, blue: 0.3, alpha: 0.4))
        components.green = 0.6
        XCTAssertEqual(components.color.colorSpace, .displayP3)
        XCTAssertEqual(components.red, 0.8, accuracy: 0.0001)
        XCTAssertEqual(components.green, 0.6, accuracy: 0.0001)
        XCTAssertEqual(components.blue, 0.3, accuracy: 0.0001)
        XCTAssertEqual(components.alpha, 0.4, accuracy: 0.0001)
    }

    func testHueSurvivesBlackAndRGBGray() {
        var components = ColorComponents(NSColor(srgbRed: 0, green: 1, blue: 0, alpha: 1))
        let hue = components.hue
        components.brightness = 0
        XCTAssertEqual(components.hue, hue)
        components.brightness = 1
        XCTAssertEqual(components.green, 1, accuracy: 0.0001)
        components.green = 0
        XCTAssertEqual(components.hue, hue)
    }

    func testHSLSaturationSurvivesWhiteAndBlack() {
        var components = ColorComponents(NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 0.5))
        components.lightness = 1
        XCTAssertEqual(components.hslSaturation, 1, accuracy: 0.0001)
        components.lightness = 0
        components.hslSaturation = 0.8
        components.lightness = 0.5
        XCTAssertEqual(components.hslSaturation, 0.8, accuracy: 0.0001)
        XCTAssertEqual(components.lightness, 0.5, accuracy: 0.0001)
        XCTAssertEqual(components.alpha, 0.5)
    }

    func testHexRoundTripAndRejectsTrailingGarbage() throws {
        let color = try XCTUnwrap(NSColor(colorSpace: .sRGB, hexString: "#1a2b3c80"))
        XCTAssertEqual(color.hexString, "1a2b3c80")
        XCTAssertNotNil(NSColor(colorSpace: .sRGB, hexString: "AABBCC"))
        XCTAssertNil(NSColor(colorSpace: .sRGB, hexString: "#aabbccxyz"))
        XCTAssertNil(NSColor(colorSpace: .sRGB, hexString: "#aabbccd"))
    }
}
