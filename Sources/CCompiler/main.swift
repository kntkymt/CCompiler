import Foundation
import CCompilerCore

struct CCompiler {
    static func main() {
        guard let source = CommandLine.arguments.dropFirst().first else {
            print("Error: please input source code")
            print("usage: ccompiler [source code]")
            return
        }

        do {
            let compiled = try compile(source)

            guard let data = compiled.data(using: .utf8) else { return }
            let currentDirectoryURL = URL(filePath: FileManager.default.currentDirectoryPath)
            let fileURL = currentDirectoryURL.appending(path: "output.s")

            do {
                try data.write(to: fileURL)
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

CCompiler.main()
