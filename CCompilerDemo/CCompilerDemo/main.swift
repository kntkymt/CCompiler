import Foundation
import CCompiler

func main() {
    let compiled = compile()
    guard let data = compiled.data(using: .utf8) else { return }

    let currentDirectoryURL = URL(filePath: FileManager.default.currentDirectoryPath)
    print(FileManager.default.currentDirectoryPath)
    let fileURL = currentDirectoryURL.appending(path: "out.s")

    do {
        try data.write(to: fileURL)
    } catch {
        print("failed to write")
    }
}

main()
