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
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(statements: [], endOfFile: TokenNode(token: tokens[0]))
        )
    }
}
