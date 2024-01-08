import XCTest
@testable import Parser
import Tokenizer

final class OperatorPriorityTest: XCTestCase {

    func testAddPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.add),
                .number("2"),
                .reserved(.add),
                .number("3"),
                .reserved(.semicolon),
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(token: tokens[0]),
                        operator: BinaryOperatorNode(token: tokens[1]),
                        right: IntegerLiteralNode(token: tokens[2])
                    ),
                    operator: BinaryOperatorNode(token: tokens[3]),
                    right: IntegerLiteralNode(token: tokens[4])
                ),
                semicolonToken: tokens[5]
            )
        )
    }

    func testMulPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.mul),
                .number("2"),
                .reserved(.mul),
                .number("3"),
                .reserved(.semicolon),
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(token: tokens[0]),
                        operator: BinaryOperatorNode(token: tokens[1]),
                        right: IntegerLiteralNode(token: tokens[2])
                    ),
                    operator: BinaryOperatorNode(token: tokens[3]),
                    right: IntegerLiteralNode(token: tokens[4])
                ),
                semicolonToken: tokens[5]
            )
        )
    }

    func testAddAndMulPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.add),
                .number("2"),
                .reserved(.mul),
                .number("3"),
                .reserved(.semicolon),
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(token: tokens[2]),
                        operator: BinaryOperatorNode(token: tokens[3]),
                        right: IntegerLiteralNode(token: tokens[4])
                    )
                ),
                semicolonToken: tokens[5]
            )
        )
    }

    func testParenthesisPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.add),
                .number("2"),
                .reserved(.parenthesisRight),
                .reserved(.mul),
                .number("3"),
                .reserved(.semicolon),
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: TupleExpressionNode(
                        parenthesisLeftToken: tokens[0],
                        expression: InfixOperatorExpressionNode(
                            left: IntegerLiteralNode(token: tokens[1]),
                            operator: BinaryOperatorNode(token: tokens[2]),
                            right: IntegerLiteralNode(token: tokens[3])
                        ),
                        parenthesisRightToken: tokens[4]
                    ),
                    operator: BinaryOperatorNode(token: tokens[5]),
                    right: IntegerLiteralNode(token: tokens[6])
                ),
                semicolonToken: tokens[7]
            )
        )
    }
}
