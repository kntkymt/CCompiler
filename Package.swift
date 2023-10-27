// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CCompiler",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "ccompiler",
            targets: ["CCompiler"]
        ),
        .library(
            name: "CCompilerCore",
            targets: ["CCompilerCore"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "CCompiler",
            dependencies: [
                "CCompilerCore"
            ]
        ),
        .target(name: "CCompilerCore"),
        .testTarget(
            name: "CCompilerCoreTest",
            dependencies: ["CCompilerCore"]
        ),
    ]
)
