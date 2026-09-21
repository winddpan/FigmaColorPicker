// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PickerDemo",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../")],
    targets: [
        .executableTarget(
            name: "PickerDemo",
            dependencies: [.product(name: "FigmaColorPicker", package: "FigmaColorPicker")]
        )
    ]
)
