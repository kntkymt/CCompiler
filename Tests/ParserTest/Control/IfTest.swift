import XCTest
@testable import Parser
import Tokenizer

final class IfTest: XCTestCase {

    func testIf() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.if),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.parenthesisRight),
                .number("2"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: IfStatementNode(
                    if: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    condition: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    parenthesisRight: TokenNode(token: tokens[3]),
                    trueBody: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[4])),
                        semicolon: TokenNode(token: tokens[5])
                    ),
                    else: nil,
                    falseBody: nil
                )
            )
        )
    }

    func testIfElse() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.if),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.parenthesisRight),
                .number("2"),
                .reserved(.semicolon),
                .keyword(.else),
                .number("3"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: IfStatementNode(
                    if: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    condition: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    parenthesisRight: TokenNode(token: tokens[3]),
                    trueBody: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[4])),
                        semicolon: TokenNode(token: tokens[5])
                    ),
                    else: TokenNode(token: tokens[6]),
                    falseBody: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[7])),
                        semicolon: TokenNode(token: tokens[8])
                    )
                )
            )
        )
    }
}
