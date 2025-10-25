// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DumpWrite",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DumpWrite",
            dependencies: [],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)
