enum ColorModel: String, CaseIterable, Identifiable {
    case hex
    case rgb
    case hsl
    case hsb

    var id: String {
        displayName
    }

    var displayName: String {
        switch self {
        case .hsb:
            return "HSB"
        case .rgb:
            return "RGB"
        case .hsl:
            return "HSL"
        case .hex:
            return "Hex"
        }
    }
}
