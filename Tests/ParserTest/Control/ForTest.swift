import XCTest
@testable import Parser
import Tokenizer

final class ForTest: XCTestCase {

    func testFor() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.semicolon),
                .number("2"),
                .reserved(.semicolon),
                .number("3"),
                .reserved(.parenthesisRight),
                .number("4"),
                .reserved(.semicolon)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.semicolon),
                .number("2"),
                .reserved(.semicolon),
                .number("3"),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("4"),
                .reserved(.semicolon),
                .number("5"),
                .reserved(.semicolon),
                .reserved(.braceRight),
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .reserved(.semicolon),
                .reserved(.semicolon),
                .reserved(.parenthesisRight),
                .number("4"),
                .reserved(.semicolon)
            ]
        )
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
