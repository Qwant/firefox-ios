// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QwantVIP",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "QwantVIP",
            targets: ["QwantVIP"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "QwantVIP"),
        .testTarget(
            name: "QwantVIPTests",
            dependencies: ["QwantVIP"]),
    ]
)
