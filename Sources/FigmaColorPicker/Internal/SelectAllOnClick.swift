import AppKit
import SwiftUI

/// macOS parks the caret where the click landed, so a pasted value lands in the
/// middle of the old one and is then rejected or clamped. `TextField` also eats
/// mouse events, which is why a tap gesture on one never runs. This overlay
/// takes the click, focuses the field and selects the whole value so ⌘V
/// replaces it, the way Figma behaves.
private struct SelectAllOnClick: ViewModifier {
    var isFocused: FocusState<Bool>.Binding

    func body(content: Content) -> some View {
        content.overlay {
            Color.clear
                .contentShape(Rectangle())
                .accessibilityHidden(true)
                .onTapGesture {
                    isFocused.wrappedValue = true
                    DispatchQueue.main.async {
                        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                    }
                }
        }
    }
}

extension View {
    func selectAllOnClick(isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(SelectAllOnClick(isFocused: isFocused))
    }
}
