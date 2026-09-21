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
                    guard let parsed = NSColor(colorSpace: color.colorSpace, hexString: input) else {
                        isInvalid = true
                        return
                    }
                    color = parsed
                    draft = parsed.hexString.uppercased()
                    isInvalid = false
                }
                .onExitCommand {
                    draft = color.hexString.uppercased()
                    isInvalid = false
                    isFocused = false
                }
                .onChange(of: draft) { _ in
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
            draft = color.hexString.uppercased()
        }
        .onChange(of: color) { value in
            draft = value.hexString.uppercased()
            isInvalid = false
        }
    }
}
