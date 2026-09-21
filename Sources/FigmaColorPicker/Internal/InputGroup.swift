import SwiftUI

struct InputGroup<Content>: View where Content: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    @ViewBuilder var content: Content

    var body: some View {
        _VariadicView
            .Tree(DividedHStackLayout(
                shouldShowDivider: true
            )) {
                content
            }
            .focused($isFocused)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .frame(height: 28)
            .background(colorScheme == .dark ? Color(white: 0.22) : Color(white: 0.92))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .onHover { isHovered in
                self.isHovered = isHovered
            }
            .onExitCommand {
                isFocused = false
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(.quaternary)
                    .opacity(isHovered ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color.accentColor)
                    .opacity(isFocused ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .animation(.easeOut(duration: 0.1), value: isFocused)
            .animation(.easeOut(duration: 0.1), value: isHovered)
    }
}

// https://movingparts.io/variadic-views-in-swiftui
struct DividedHStackLayout: _VariadicView_UnaryViewRoot {
    var shouldShowDivider: Bool

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id

        HStack(spacing: 0) {
            ForEach(children) { child in
                child

                if child.id != last {
                    Rectangle()
                        .fill(Color.primary.opacity(0.5))
                        .colorInvert()
                        .frame(width: 1)
                        .opacity(shouldShowDivider ? 1 : 0)
                }
            }
        }
    }
}
