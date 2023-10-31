// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CCompiler",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "ccompiler",
            targets: ["CCompiler"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CCompiler",
            dependencies: [
                "CCompilerCore"
            ]
        ),
        .target(
            name: "CCompilerCore",
            dependencies: [
                "Tokenizer"
            ]
        ),
        .target(
            name: "Tokenizer"
        ),
        .testTarget(
            name: "CCompilerCoreTest",
            dependencies: ["CCompilerCore"]
        ),
        .testTarget(
            name: "TokenizerTest",
            dependencies: ["Tokenizer"]
        ),
    ]
)
