import AppKit

// Editing coordinates preserve hue/saturation at black and white, where RGB
// cannot represent them. The caller's binding remains the committed color.
struct ColorComponents {
    var hue: Double
    var saturation: Double
    var brightness: Double
    var alpha: Double
    var colorSpace: ColorSpace
    private var achromaticHSLSaturation = 0.0

    init(_ color: NSColor) {
        colorSpace = color.type == .componentBased && color.colorSpace == .displayP3
            ? .displayP3 : .sRGB
        let rgb = color.usingColorSpace(colorSpace.nsColorSpace)
            ?? NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        hue = rgb.hueComponent.clamped(to: 0 ... 1)
        saturation = rgb.saturationComponent.clamped(to: 0 ... 1)
        brightness = rgb.brightnessComponent.clamped(to: 0 ... 1)
        alpha = rgb.alphaComponent.clamped(to: 0 ... 1)
    }

    var color: NSColor {
        NSColor(colorSpace: colorSpace.nsColorSpace, hue: hue,
                saturation: saturation, brightness: brightness, alpha: alpha)
    }

    var lightness: Double {
        get { brightness * (1 - saturation / 2) }
        set {
            let hslSaturation = self.hslSaturation
            achromaticHSLSaturation = hslSaturation
            brightness = newValue + hslSaturation * min(newValue, 1 - newValue)
            saturation = brightness == 0 ? 0 : 2 * (1 - newValue / brightness)
        }
    }

    var hslSaturation: Double {
        get {
            lightness == 0 || lightness == 1
                ? achromaticHSLSaturation : (brightness - lightness) / min(lightness, 1 - lightness)
        }
        set {
            let lightness = self.lightness
            achromaticHSLSaturation = newValue
            brightness = lightness + newValue * min(lightness, 1 - lightness)
            saturation = brightness == 0 ? 0 : 2 * (1 - lightness / brightness)
        }
    }

    var red: Double {
        get { color.redComponent }
        set { setRGB(red: newValue, green: green, blue: blue) }
    }

    var green: Double {
        get { color.greenComponent }
        set { setRGB(red: red, green: newValue, blue: blue) }
    }

    var blue: Double {
        get { color.blueComponent }
        set { setRGB(red: red, green: green, blue: newValue) }
    }

    private mutating func setRGB(red: Double, green: Double, blue: Double) {
        let rgb = NSColor(colorSpace: colorSpace.nsColorSpace,
                          components: [red, green, blue, alpha], count: 4)
        let previousHue = hue
        self = ColorComponents(rgb)
        if saturation == 0 { hue = previousHue }
    }
}
