// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "venc",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "venc", path: "Sources/venc"),
    ]
)
