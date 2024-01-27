import XCTest
@testable import Parser
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
    }
}
