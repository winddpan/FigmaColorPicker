import AppKit
import SwiftUI

/// Restores the standard ⌘X / ⌘C / ⌘V / ⌘A editing keys inside the popover.
///
/// macOS does not bind those keys to a text field. `NSApplication.sendEvent`
/// hands a command key-down to `NSApp.mainMenu.performKeyEquivalent` first, and
/// the Edit menu's `copy:` / `paste:` items carry it down the responder chain
/// from there. A menu bar app, or any host that replaced the default menu, has
/// no Edit menu to start that trip, and `TextField` — an `AppKitTextField`
/// driving an `NSTextView` field editor — does not handle the keys itself, so
/// the shortcut dies. Watching the keys locally and forwarding them straight to
/// the responder chain gives the same result without needing a menu. The host
/// keeps its own wiring when it does own an Edit menu.
private struct TextEditingShortcuts: NSViewRepresentable {
    final class Coordinator {
        private var monitor: Any?

        func start() {
            guard monitor == nil else { return }

            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard event.modifierFlags.intersection([.command, .option, .control]) == .command,
                      NSApp.keyWindow?.firstResponder is NSTextView,
                      let key = event.charactersIgnoringModifiers?.lowercased()
                else { return event }

                let action: Selector
                switch key {
                case "x": action = #selector(NSText.cut(_:))
                case "c": action = #selector(NSText.copy(_:))
                case "v": action = #selector(NSText.paste(_:))
                case "a": action = #selector(NSText.selectAll(_:))
                default: return event
                }

                // An Edit menu is the authority when one is present, even if it
                // was added by the host or by SwiftUI itself.
                if NSApp.mainMenu?.performKeyEquivalent(with: event) == true {
                    return nil
                }

                NSApp.sendAction(action, to: nil, from: nil)
                return nil
            }
        }

        func stop() {
            guard let monitor else { return }
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }

        deinit {
            stop()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.start()
        return NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.stop()
    }
}

extension View {
    /// Keeps the clipboard and selection keys working while this view is on
    /// screen, in hosts that have no Edit menu to route them.
    func textEditingShortcuts() -> some View {
        background(TextEditingShortcuts().frame(width: 0, height: 0))
    }
}
