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
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "CCompiler",
            dependencies: [
                "CCompilerCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "CCompilerCore",
            dependencies: [
                "Tokenizer",
                "Parser",
                "AST",
                "Generator",
                "Optimizer"
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
            name: "AST",
            dependencies: [
                "Parser"
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                "AST"
            ]
        ),
        .target(
            name: "Optimizer",
            dependencies: [
                "Generator"
            ]
        ),
        .testTarget(
            name: "CCompilerCoreTest",
            dependencies: ["CCompilerCore"]
        ),
        .testTarget(
            name: "OptimizerTest",
            dependencies: ["Optimizer"]
        ),
        .testTarget(
            name: "GeneratorTest",
            dependencies: ["Generator"]
        ),
        .testTarget(
            name: "ParserTest",
            dependencies: ["Parser", "AST"]
        ),
        .testTarget(
            name: "TokenizerTest",
            dependencies: ["Tokenizer"]
        ),
    ]
)
