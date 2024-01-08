import XCTest
@testable import Parser
import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral1() throws {
        let tokens: [Token] = [
            Token(kind: .stringLiteral("a"), sourceIndex: 0),
            Token(kind: .reserved(.semicolon), sourceIndex: 1)
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
            Token(kind: .identifier("a"), sourceIndex: 0),
            Token(kind: .reserved(.assign), sourceIndex: 1),
            Token(kind: .stringLiteral("a"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
