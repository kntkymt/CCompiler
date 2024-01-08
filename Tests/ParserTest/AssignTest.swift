import XCTest
@testable import Parser
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .number("2"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }

    func testAssignTo2Var() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .identifier("b"),
                .reserved(.assign),
                .number("2"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: InfixOperatorExpressionNode(
                        left: IdentifierNode(token: tokens[2]),
                        operator: AssignNode(token: tokens[3]),
                        right: IntegerLiteralNode(token: tokens[4])
                    )
                ),
                semicolonToken: tokens[5]
            )
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.assign),
                .number("2"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }
}
