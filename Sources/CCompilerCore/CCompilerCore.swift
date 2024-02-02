import Parser
import AST
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
        let syntax = try Parser(tokens: tokens).parse()
        let node = ASTGenerator.generate(sourceFileSyntax: syntax)
        let asm = try Generator().generate(sourceFileNode: node)
        
        return ArmAsmPrinter.print(instructions: asm)
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
