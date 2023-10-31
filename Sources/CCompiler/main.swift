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
        } catch {
            print("failed to compile")
        }
    }
}

CCompiler.main()
