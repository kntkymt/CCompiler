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
                    ifToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    condition: IntegerLiteralNode(token: tokens[2]),
                    parenthesisRightToken: tokens[3],
                    trueBody: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[4]),
                        semicolonToken: tokens[5]
                    ),
                    elseToken: nil,
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
                    ifToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    condition: IntegerLiteralNode(token: tokens[2]),
                    parenthesisRightToken: tokens[3],
                    trueBody: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[4]),
                        semicolonToken: tokens[5]
                    ),
                    elseToken: tokens[6],
                    falseBody: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[7]),
                        semicolonToken: tokens[8]
                    )
                )
            )
        )
    }
}
