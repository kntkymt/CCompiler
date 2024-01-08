import XCTest
@testable import Parser
import Tokenizer

final class ReturnTest: XCTestCase {

    func testReturn() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.return),
                .number("2"),
                .reserved(.semicolon),
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ReturnStatementNode(
                    returnToken: tokens[0],
                    expression: IntegerLiteralNode(token: tokens[1])
                ),
                semicolonToken: tokens[2]
            )
        )
    }

    func testReturnNoExpr() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .keyword(.return),
                        .reserved(.semicolon),
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 7)))
        }
    }
}
