import SwiftUI

struct HexInputGroup: View {
    @Binding var color: NSColor
    @State private var draft = ""
    @State private var isInvalid = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            TextField("RRGGBB", text: $draft)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.leading)
                .focused($isFocused)
                .accessibilityLabel("Hex color")
                .onSubmit {
                    let input = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard commit(input) else {
                        isInvalid = true
                        return
                    }
                    draft = color.rgbHexString.uppercased()
                    isInvalid = false
                }
                .onExitCommand {
                    draft = color.rgbHexString.uppercased()
                    isInvalid = false
                    isFocused = false
                }
                .onChange(of: draft) { value in
                    isInvalid = false
                    // An 8-digit value hands alpha to the alpha control and
                    // collapses back to the six digits this field shows.
                    let input = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard input.drop(while: { $0 == "#" }).count == 8, commit(input) else { return }
                    draft = color.rgbHexString.uppercased()
                }
                .onChange(of: isFocused) { focused in
                    guard !focused else { return }
                    draft = color.rgbHexString.uppercased()
                    isInvalid = false
                }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .trailing) {
            if isInvalid {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.red)
                    .padding(.trailing, 2)
                    .accessibilityLabel("Invalid hex color")
                    .help("Enter a 6- or 8-digit hex color")
            }
        }
        .onAppear {
            draft = color.rgbHexString.uppercased()
        }
        .onChange(of: color) { value in
            draft = value.rgbHexString.uppercased()
            isInvalid = false
        }
    }

    /// Applies a parsed hex string. Six digits edit RGB only and leave alpha to
    /// the alpha control; eight digits carry alpha in their last two digits.
    private func commit(_ input: String) -> Bool {
        guard let parsed = NSColor(colorSpace: color.colorSpace, hexString: input) else {
            return false
        }

        let digits = input.drop { $0 == "#" }
        color = digits.count == 6 ? parsed.withAlphaComponent(color.alphaComponent) : parsed
        return true
    }
}
