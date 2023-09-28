// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CCompiler",
    products: [
        .library(
            name: "CCompiler",
            targets: ["CCompiler"]),
    ],
    targets: [
        .target(
            name: "CCompiler"),
        .testTarget(
            name: "CCompilerTest",
            dependencies: ["CCompiler"]),
    ]
)
