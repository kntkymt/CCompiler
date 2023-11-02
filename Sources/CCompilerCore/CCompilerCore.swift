import Parser
import Generator
import Tokenizer

public enum CompileError: Error, Equatable {
    case invalidSyntax(index: Int)
    case invalidToken(index: Int)
    case unknown
}

public func compile(_ source: String) throws -> String {
    var compiled = ".globl _main\n"
    compiled += "_main:\n"

    let rootNode = try {
        do {
            return try parse(source)
        } catch let error as ParseError {
            switch error {
            case .invalidSyntax(let index):
                throw CompileError.invalidSyntax(index: index)
            }

        } catch let error as TokenizeError {
            switch error {
            case .unknownToken(let index):
                throw CompileError.invalidToken(index: index)
            }

        } catch {
            throw CompileError.unknown
        }
    }()

    compiled += generate(node: rootNode)

    compiled += "    ldr w0, [sp]\n"
    compiled += "    add sp, sp, #16\n"
    compiled += "    ret\n"

    return compiled
}
