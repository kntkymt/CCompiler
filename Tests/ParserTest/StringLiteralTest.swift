import XCTest
@testable import Parser
import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral1() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .stringLiteral("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: StringLiteralNode(literal: TokenNode(token: tokens[0])),
                semicolon: TokenNode(token: tokens[1])
            )
        )
    }

    func testStringLiteral2() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .stringLiteral("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(baseName: TokenNode(token: tokens[0])),
                    operator: AssignNode(equal: TokenNode(token: tokens[1])),
                    right: StringLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }
}
