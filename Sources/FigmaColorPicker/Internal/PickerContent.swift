import SwiftUI

struct PickerContent: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var selection: NSColor
    @State private var components: ColorComponents
    @State private var model = ColorModel.hex
    @State private var isSampling = false
    @State private var sampler = NSColorSampler()

    init(selection: Binding<NSColor>) {
        _selection = selection
        _components = State(initialValue: ColorComponents(selection.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 16) {
            Group {
                if model == .hsl {
                    SaturationLightnessSlider(
                        hue: components.hue, saturation: component(\.hslSaturation),
                        lightness: component(\.lightness), colorSpace: components.colorSpace
                    )
                } else {
                    SaturationBrightnessSlider(
                        hue: components.hue, saturation: component(\.saturation),
                        brightness: component(\.brightness), colorSpace: components.colorSpace
                    )
                }
            }
            .frame(height: 242)

            HStack(spacing: 12) {
                Button {
                    isSampling = true
                    sampler.show { color in
                        isSampling = false
                        if let color = color?.usingColorSpace(components.colorSpace.nsColorSpace) {
                            selection = color
                            components = ColorComponents(color)
                        }
                    }
                } label: {
                    Image(systemName: "eyedropper")
                        .font(.system(size: 18))
                        .frame(width: 16, height: 24)
                }
                .buttonStyle(.solid)
                .disabled(isSampling)
 

                VStack(spacing: 14) {
                    HueSlider(hue: component(\.hue), colorSpace: components.colorSpace)
                    AlphaSlider(alpha: component(\.alpha),
                                color: Color(nsColor: components.color.withAlphaComponent(1)))
                }
            }

            HStack(spacing: 12) {
                ZStack {
                    HStack(spacing: 0) {
                        Text(model.displayName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 28)
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)

                    ColorModelMenu(selection: $model)
                }
                .frame(width: 65, height: 28)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.primary.opacity(0.13))
                        .allowsHitTesting(false)
                }

                switch model {
                case .hsb:
                    HSBAInputGroup(hue: component(\.hue), saturation: component(\.saturation),
                                   brightness: component(\.brightness), alpha: component(\.alpha))
                case .hsl:
                    HSLAInputGroup(hue: component(\.hue), saturation: component(\.hslSaturation),
                                   lightness: component(\.lightness), alpha: component(\.alpha))
                case .rgb:
                    RGBAInputGroup(red: component(\.red), green: component(\.green),
                                   blue: component(\.blue), alpha: component(\.alpha))
                case .hex:
                    InputGroup {
                        HexInputGroup(color: Binding {
                            components.color
                        } set: { color in
                            components = ColorComponents(color)
                            selection = components.color
                        })
                        PercentageInput("Alpha", value: component(\.alpha).percentage)
                    }
                }
            }
            .frame(height: 32)
        }
        .font(.system(size: 12))
        .padding(18)
        .frame(width: 280)
        .background(colorScheme == .dark ? Color(white: 0.17) : Color(white: 0.98))
        .onAppear {
            components = ColorComponents(selection)
        }
        .onChange(of: selection) { _, color in
            // Ignore our own writes so hue survives achromatic colors.
            guard color != components.color else { return }
            components = ColorComponents(color)
        }
    }

    private func component(_ keyPath: WritableKeyPath<ColorComponents, Double>) -> Binding<Double> {
        Binding {
            components[keyPath: keyPath]
        } set: { value in
            components[keyPath: keyPath] = value.clamped(to: 0 ... 1)
            selection = components.color
        }
    }
}

#Preview {
    @Previewable @State  var color: NSColor = .red

    PickerContent(selection: $color)
}
