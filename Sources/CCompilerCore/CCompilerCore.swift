import Parser
import Generator
import Tokenizer

public enum CompileError: Error, Equatable {
    case invalidSyntax(index: Int)
    case invalidToken(index: Int)
    case unknown
}

public func compile(_ source: String) throws -> String {
    let tokens = try {
        do {
            return try tokenize(source: source)
        } catch let error as TokenizeError {
            switch error {
            case .unknownToken(let index):
                throw CompileError.invalidToken(index: index)
            }

        } catch {
            throw CompileError.unknown
        }
    }()
    let node = try {
        do {
            return try Parser(tokens: tokens).parse()
        } catch let error as ParseError {
            switch error {
            case .invalidSyntax(let index):
                throw CompileError.invalidSyntax(index: index)
            }

        } catch {
            throw CompileError.unknown
        }
    }()

    do {
        return try Generator().generate(sourceFileNode: node)
    } catch let error as GenerateError {
        switch error {
        case .invalidSyntax(let index):
            throw CompileError.invalidSyntax(index: index)
        }
    } catch {
        throw CompileError.unknown
    }
}
