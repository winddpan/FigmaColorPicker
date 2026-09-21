import SwiftUI
import FigmaColorPicker

@main
struct PickerDemo: App {
    var body: some Scene {
        WindowGroup {
            DemoContent()
                .padding(24)
                .frame(width: 440, height: 240)
                .onAppear {
                    NSApplication.shared.setActivationPolicy(.regular)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
    }
}

private struct DemoContent: View {
    @State private var color = NSColor.systemRed
    @State private var showsPicker = false
    @State private var appearance = ColorScheme.dark

    var body: some View {
        VStack(spacing: 20) {
            Picker("Appearance", selection: $appearance) {
                Label("Light", systemImage: "sun.max").tag(ColorScheme.light)
                Label("Dark", systemImage: "moon").tag(ColorScheme.dark)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)

            HStack(spacing: 16) {
                FigmaColorPicker(selection: $color)
                Button("Custom trigger") { showsPicker = true }
                    .figmaColorPickerPopover(isPresented: $showsPicker, selection: $color)
                Color(nsColor: color).frame(width: 80, height: 44)
            }
            HStack {
                Button("Set blue") { color = .systemBlue }
                Button("Set gray") { color = NSColor(deviceWhite: 0.5, alpha: 0.5) }
                Button("Set P3") {
                    color = NSColor(displayP3Red: 1, green: 0.4, blue: 0, alpha: 0.7)
                }
            }
        }
        .preferredColorScheme(appearance)
        .environment(\.colorScheme, appearance)
        .onAppear {
            if CommandLine.arguments.contains("--show-picker") {
                showsPicker = true
            }
        }
    }
}
