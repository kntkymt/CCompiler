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
                "Tokenizer",
                "Parser",
                "Generator"
            ]
        ),
        .target(
            name: "Tokenizer"
        ),
        .target(
            name: "Parser",
            dependencies: [
                "Tokenizer"
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                "Parser"
            ]
        ),
        .testTarget(
            name: "CCompilerCoreTest",
            dependencies: ["CCompilerCore"]
        ),
        .testTarget(
            name: "ParserTest",
            dependencies: ["Parser"]
        ),
        .testTarget(
            name: "TokenizerTest",
            dependencies: ["Tokenizer"]
        ),
    ]
)
