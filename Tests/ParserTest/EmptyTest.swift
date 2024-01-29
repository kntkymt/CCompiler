import XCTest
@testable import Parser
@testable import AST
import Tokenizer

final class EmptyTest: XCTestCase {

    func testEmpty() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(statements: [], endOfFile: TokenSyntax(token: tokens[0]))
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(statements: [], sourceRange: tokens[0].sourceRange)
        )
    }
}
