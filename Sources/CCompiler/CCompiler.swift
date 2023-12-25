import Foundation
import CCompilerCore
import ArgumentParser

@main
struct Ccompiler: ParsableCommand {

    @Argument(help: "The path to the input source code file.", completion: .file())
    var inputFilePath: String

    @Option(name: .shortAndLong, help: "The path to the output file.", completion: .file())
    var outputFilePath: String?

    mutating func run() {
        let currentDirectoryURL = URL(filePath: FileManager.default.currentDirectoryPath)
        let inputPath = currentDirectoryURL.appendingPathComponent(inputFilePath)
        guard let source = try? String(contentsOf: inputPath, encoding: .utf8) else {
            print("no such file \(inputFilePath)")
            return
        }

        do {
            let compiled = try compile(source)

            guard let data = compiled.data(using: .utf8) else { return }
            let outputURL: URL
            if let outputFilePath {
                outputURL = currentDirectoryURL.appending(path: outputFilePath)
            } else {
                let filename = inputPath.lastPathComponent.prefix { $0 != "." }
                outputURL = currentDirectoryURL.appending(path: filename + ".s")
            }

            do {
                try data.write(to: outputURL)
            } catch {
                print("failed to write")
            }
        } catch let error as CompileError {
            switch error {
            case .invalidSyntax(let index):
                print(source)
                print(String(repeating: " ", count: index) + "^不正な文法です")
            case .invalidToken(let index):
                print(source)
                print(String(repeating: " ", count: index) + "^不正な文字です")
            case .noSuchVariable(let variableName, let index):
                print(source)
                print(String(repeating: " ", count: index) + "^変数\(variableName)は存在しません")

            case .unknown:
                print("不明なコンパイルエラー")
            }
        } catch {
            print("不明なコンパイルエラー")
        }
    }
}
