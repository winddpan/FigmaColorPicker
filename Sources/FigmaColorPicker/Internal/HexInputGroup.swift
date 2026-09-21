import AppKit
import SwiftUI

struct HexInputGroup: View {
    @Binding var color: NSColor
    @State private var draft = ""
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
                    // A value that does not parse is rejected, and the field
                    // falls back to the last colour that did, left selected so
                    // the next paste replaces it.
                    guard commit(input) else {
                        draft = color.rgbHexString.uppercased()
                        DispatchQueue.main.async {
                            NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                        }
                        return
                    }
                    draft = color.rgbHexString.uppercased()
                }
                .onExitCommand {
                    draft = color.rgbHexString.uppercased()
                    isFocused = false
                }
                .onChange(of: draft) { value in
                    // An 8-digit value hands alpha to the alpha control and
                    // collapses back to the six digits this field shows.
                    let input = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard input.drop(while: { $0 == "#" }).count == 8, commit(input) else { return }
                    draft = color.rgbHexString.uppercased()
                }
                .onChange(of: isFocused) { focused in
                    guard !focused else { return }
                    // Whatever is left in the field is applied on the way out,
                    // the way the alpha field commits on blur. Escape is the
                    // way to back out of an edit.
                    _ = commit(draft.trimmingCharacters(in: .whitespacesAndNewlines))
                    draft = color.rgbHexString.uppercased()
                }
                .selectAllOnClick(isFocused: $isFocused)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            draft = color.rgbHexString.uppercased()
        }
        .onChange(of: color) { value in
            draft = value.rgbHexString.uppercased()
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
