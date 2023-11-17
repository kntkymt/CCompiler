import XCTest
@testable import Parser
import Tokenizer

final class WhileTest: XCTestCase {

    func testWhile() throws {
        let tokens: [Token] = [
            .keyword(.while, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 5),
            .number("1", sourceIndex: 6),
            .reserved(.parenthesisRight, sourceIndex: 7),
            .number("2", sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ]
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! WhileStatementNode,
            WhileStatementNode(
                token: tokens[0],
                condition: IntegerLiteralNode(token: tokens[2]),
                body: IntegerLiteralNode(token: tokens[4]),
                sourceTokens: Array(tokens[0...5])
            )
        )
    }

    func testWhileNoExpr() throws {
        do {
            _ = try parse(tokens: [
                .keyword(.while, sourceIndex: 0),
                .reserved(.parenthesisLeft, sourceIndex: 5),
                .number("1", sourceIndex: 6),
                .reserved(.parenthesisRight, sourceIndex: 7),
                .reserved(.semicolon, sourceIndex: 8)
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 8))
        }
    }
}
