// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FigmaColorPicker",
    platforms: [.macOS(.v14)],
    products: [.library(name: "FigmaColorPicker", targets: ["FigmaColorPicker"])],
    targets: [
        .target(name: "FigmaColorPicker"),
        .testTarget(name: "FigmaColorPickerTests", dependencies: ["FigmaColorPicker"])
    ]
)
