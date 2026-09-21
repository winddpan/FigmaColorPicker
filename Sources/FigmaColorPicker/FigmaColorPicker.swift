import SwiftUI

/// A color swatch button that opens the color editor in a popover.
/// Changes are written to `selection` immediately, including alpha.
public struct FigmaColorPicker: View {
    @Binding private var selection: NSColor
    @State private var isPresented = false

    public init(selection: Binding<NSColor>) {
        _selection = selection
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            ColorSwatch(color: selection)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Choose color")
        .help("Choose color")
        .figmaColorPickerPopover(isPresented: $isPresented, selection: $selection)
    }
}

public extension View {
    /// Attaches a color editor to any view. The caller owns both bindings.
    /// The editor uses Display P3 for P3 input, and sRGB for other input.
    /// Dismissing the popover keeps edits; it does not roll them back.
    func figmaColorPickerPopover(
        isPresented: Binding<Bool>,
        selection: Binding<NSColor>,
        arrowEdge: Edge = .bottom
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            PickerContent(selection: selection)
        }
    }
}
