import Parser
import Generator
import Tokenizer

public enum CompileError: Error, Equatable {
    case invalidSyntax(location: SourceLocation)
    case invalidToken(location: SourceLocation)
    case noSuchVariable(variableName: String, location: SourceLocation)
    case unknown
}

public func compile(_ source: String) throws -> String {
    do {
        let tokens = try Tokenizer(source: source).tokenize()
        let node = try Parser(tokens: tokens).parse()

        return try Generator().generate(sourceFileNode: node)
    } catch let error as TokenizeError {
        switch error {
        case .unknownToken(let location):
            throw CompileError.invalidToken(location: location)
        }
    } catch let error as ParseError {
        switch error {
        case .invalidSyntax(let location):
            throw CompileError.invalidSyntax(location: location)
        }
    } catch let error as GenerateError {
        switch error {
        case .invalidSyntax(let location):
            throw CompileError.invalidSyntax(location: location)

        case .noSuchVariable(let variableName, let location):
            throw CompileError.noSuchVariable(variableName: variableName, location: location)

        }
    } catch {
        throw CompileError.unknown
    }
}
