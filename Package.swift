// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModalKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "ModalKit", targets: ["ModalKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ModalKit",
            dependencies: [],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
