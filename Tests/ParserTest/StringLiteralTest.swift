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

        XCTAssertEqual(
            node as! StringLiteralNode,
            StringLiteralNode(token: tokens[0])
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

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: AssignNode(token: tokens[1]),
                left: IdentifierNode(token: tokens[0]),
                right: StringLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }
}
