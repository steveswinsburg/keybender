// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeyBender",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "KeyBender",
            path: "Sources/KeyBender"
        )
    ]
)
