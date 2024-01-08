import Parser
import Generator
import Tokenizer

public enum CompileError: Error, Equatable {
    case invalidSyntax(index: Int)
    case invalidToken(index: Int)
    case noSuchVariable(variableName: String, index: Int)
    case unknown
}

public func compile(_ source: String) throws -> String {
    do {
        let tokens = try Tokenizer(source: source).tokenize()
        let node = try Parser(tokens: tokens).parse()

        return try Generator().generate(sourceFileNode: node)
    } catch let error as TokenizeError {
        switch error {
        case .unknownToken(let index):
            throw CompileError.invalidToken(index: index)
        }
    } catch let error as ParseError {
        switch error {
        case .invalidSyntax(let index):
            throw CompileError.invalidSyntax(index: index)
        }
    } catch let error as GenerateError {
        switch error {
        case .invalidSyntax(let index):
            throw CompileError.invalidSyntax(index: index)

        case .noSuchVariable(let variableName, let index):
            throw CompileError.noSuchVariable(variableName: variableName, index: index)

        }
    } catch {
        throw CompileError.unknown
    }
}
