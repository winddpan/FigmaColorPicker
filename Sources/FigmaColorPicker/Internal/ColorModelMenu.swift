import SwiftUI

// Keep the SwiftUI label's dimensions; native Menu labels use the macOS
// compact control layout, which ignores the input row's height and spacing.
struct ColorModelMenu: NSViewRepresentable {
    @Binding var selection: ColorModel

    func makeNSView(context: Context) -> MenuAnchor {
        MenuAnchor()
    }

    func updateNSView(_ view: MenuAnchor, context: Context) {
        view.selection = selection
        view.onSelect = { selection = $0 }
        view.setAccessibilityValue(selection.displayName)
    }

    final class MenuAnchor: NSView {
        var selection = ColorModel.hsb
        var onSelect: ((ColorModel) -> Void)?

        override init(frame: NSRect) {
            super.init(frame: frame)
            setAccessibilityElement(true)
            setAccessibilityRole(.popUpButton)
            setAccessibilityLabel("Color model")
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) is unavailable")
        }

        override var acceptsFirstResponder: Bool { true }

        override func mouseDown(with event: NSEvent) {
            showMenu()
        }

        override func keyDown(with event: NSEvent) {
            if [36, 49, 125, 126].contains(event.keyCode) {
                showMenu()
            } else {
                super.keyDown(with: event)
            }
        }

        override func accessibilityPerformPress() -> Bool {
            showMenu()
            return true
        }

        private func showMenu() {
            let menu = NSMenu()
            menu.font = .systemFont(ofSize: 12)
            for (index, model) in ColorModel.allCases.enumerated() {
                let item = NSMenuItem(title: model.displayName,
                                      action: #selector(selectModel(_:)), keyEquivalent: "")
                item.target = self
                item.tag = index
                item.state = model == selection ? .on : .off
                menu.addItem(item)
            }
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: bounds.height), in: self)
        }

        @objc private func selectModel(_ item: NSMenuItem) {
            onSelect?(ColorModel.allCases[item.tag])
        }
    }
}
