import XCTest
@testable import Parser
import Tokenizer

final class ForTest: XCTestCase {

    func testFor() throws {
        let tokens: [Token] = [
            Token(kind: .keyword(.for), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 3),
            Token(kind: .number("1"), sourceIndex: 4),
            Token(kind: .reserved(.semicolon), sourceIndex: 5),
            Token(kind: .number("2"), sourceIndex: 6),
            Token(kind: .reserved(.semicolon), sourceIndex: 7),
            Token(kind: .number("3"), sourceIndex: 8),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 9),
            Token(kind: .number("4"), sourceIndex: 10),
            Token(kind: .reserved(.semicolon), sourceIndex: 11)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ForStatementNode(
                    forToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    pre: IntegerLiteralNode(token: tokens[2]),
                    firstSemicolonToken: tokens[3],
                    condition: IntegerLiteralNode(token: tokens[4]),
                    secondSemicolonToken: tokens[5],
                    post: IntegerLiteralNode(token: tokens[6]),
                    parenthesisRightToken: tokens[7],
                    body: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[8]),
                        semicolonToken: tokens[9]
                    )
                )
            )
        )
    }

    func testForBlock() throws {
        let tokens: [Token] = [
            Token(kind: .keyword(.for), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 3),
            Token(kind: .number("1"), sourceIndex: 4),
            Token(kind: .reserved(.semicolon), sourceIndex: 5),
            Token(kind: .number("2"), sourceIndex: 6),
            Token(kind: .reserved(.semicolon), sourceIndex: 7),
            Token(kind: .number("3"), sourceIndex: 8),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 9),
            Token(kind: .reserved(.braceLeft), sourceIndex: 10),
            Token(kind: .number("4"), sourceIndex: 10),
            Token(kind: .reserved(.semicolon), sourceIndex: 11),
            Token(kind: .number("5"), sourceIndex: 12),
            Token(kind: .reserved(.semicolon), sourceIndex: 13),
            Token(kind: .reserved(.braceRight), sourceIndex: 14)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ForStatementNode(
                    forToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    pre: IntegerLiteralNode(token: tokens[2]),
                    firstSemicolonToken: tokens[3],
                    condition: IntegerLiteralNode(token: tokens[4]),
                    secondSemicolonToken: tokens[5],
                    post: IntegerLiteralNode(token: tokens[6]),
                    parenthesisRightToken: tokens[7],
                    body: BlockItemNode(
                        item: BlockStatementNode(
                            braceLeftToken: tokens[8],
                            items: [
                                BlockItemNode(item: IntegerLiteralNode(token: tokens[9]), semicolonToken: tokens[10]),
                                BlockItemNode(item: IntegerLiteralNode(token: tokens[11]), semicolonToken: tokens[12])
                            ],
                            braceRightToken: tokens[13]
                        )
                    )
                )
            )
        )
    }

    func testForNoNodes() throws {
        let tokens: [Token] = [
            Token(kind: .keyword(.for), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4),
            Token(kind: .reserved(.semicolon), sourceIndex: 5),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 6),
            Token(kind: .number("4"), sourceIndex: 7),
            Token(kind: .reserved(.semicolon), sourceIndex: 8)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ForStatementNode(
                    forToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    pre: nil,
                    firstSemicolonToken: tokens[2],
                    condition: nil,
                    secondSemicolonToken: tokens[3],
                    post: nil,
                    parenthesisRightToken: tokens[4],
                    body: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[5]),
                        semicolonToken: tokens[6]
                    )
                )
            )
        )
    }
}
