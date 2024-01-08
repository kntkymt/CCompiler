import XCTest
@testable import Parser
import Tokenizer

final class ReturnTest: XCTestCase {

    func testReturn() throws {
        let tokens: [Token] = [
            Token(kind: .keyword(.return), sourceIndex: 0),
            Token(kind: .number("2"), sourceIndex: 6),
            Token(kind: .reserved(.semicolon), sourceIndex: 7),
        ]
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
            _ = try Parser(tokens: [
                Token(kind: .keyword(.return), sourceIndex: 0),
                Token(kind: .reserved(.semicolon), sourceIndex: 7),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 7))
        }
    }
}
