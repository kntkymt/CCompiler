import XCTest
@testable import Parser
import Tokenizer

final class WhileTest: XCTestCase {

    func testWhile() throws {
        let tokens: [Token] = [
            Token(kind: .keyword(.while), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 5),
            Token(kind: .number("1"), sourceIndex: 6),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 7),
            Token(kind: .number("2"), sourceIndex: 8),
            Token(kind: .reserved(.semicolon), sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: WhileStatementNode(
                    whileToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    condition: IntegerLiteralNode(token: tokens[2]),
                    parenthesisRightToken: tokens[3],
                    body: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[4]),
                        semicolonToken: tokens[5]
                    )
                )
            )
        )
    }

    func testWhileNoExpr() throws {
        do {
            _ = try Parser(tokens: [
                Token(kind: .keyword(.while), sourceIndex: 0),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 5),
                Token(kind: .number("1"), sourceIndex: 6),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 7),
                Token(kind: .reserved(.semicolon), sourceIndex: 8)
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 8))
        }
    }
}
