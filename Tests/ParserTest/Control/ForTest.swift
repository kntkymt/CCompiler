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
                    for: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    pre: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    firstSemicolon: TokenNode(token: tokens[3]),
                    condition: IntegerLiteralNode(literal: TokenNode(token: tokens[4])),
                    secondSemicolon: TokenNode(token: tokens[5]),
                    post: IntegerLiteralNode(literal: TokenNode(token: tokens[6])),
                    parenthesisRight: TokenNode(token: tokens[7]),
                    body: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[8])),
                        semicolon: TokenNode(token: tokens[9])
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
                .reserved(.braceRight)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ForStatementNode(
                    for: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    pre: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    firstSemicolon: TokenNode(token: tokens[3]),
                    condition: IntegerLiteralNode(literal: TokenNode(token: tokens[4])),
                    secondSemicolon: TokenNode(token: tokens[5]),
                    post: IntegerLiteralNode(literal: TokenNode(token: tokens[6])),
                    parenthesisRight: TokenNode(token: tokens[7]),
                    body: BlockItemNode(
                        item: BlockStatementNode(
                            braceLeft: TokenNode(token: tokens[8]),
                            items: [
                                BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[9])), semicolon: TokenNode(token: tokens[10])),
                                BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[11])), semicolon: TokenNode(token: tokens[12]))
                            ],
                            braceRight: TokenNode(token: tokens[13])
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
                    for: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    pre: nil,
                    firstSemicolon: TokenNode(token: tokens[2]),
                    condition: nil,
                    secondSemicolon: TokenNode(token: tokens[3]),
                    post: nil,
                    parenthesisRight: TokenNode(token: tokens[4]),
                    body: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[5])),
                        semicolon: TokenNode(token: tokens[6])
                    )
                )
            )
        )
    }
}
