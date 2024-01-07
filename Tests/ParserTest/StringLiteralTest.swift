import XCTest
@testable import Parser
import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral1() throws {
        let tokens: [Token] = [
            .stringLiteral("a", sourceIndex: 0),
            .reserved(.semicolon, sourceIndex: 1)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: StringLiteralNode(token: tokens[0]),
                semicolonToken: tokens[1]
            )
        )
    }

    func testStringLiteral2() throws {
        let tokens: [Token] = [
            .identifier("a", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .stringLiteral("a", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: StringLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }
}
