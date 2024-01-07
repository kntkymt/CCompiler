import XCTest
@testable import Parser
import Tokenizer

final class OperatorPriorityTest: XCTestCase {

    func testAddPriority() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.add, sourceIndex: 3),
            .number("3", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
        ]
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
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.mul, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.mul, sourceIndex: 3),
            .number("3", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
        ]
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
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.mul, sourceIndex: 3),
            .number("3", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
        ]
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
        let tokens: [Token] = [
            .reserved(.parenthesisLeft, sourceIndex: 0),
            .number("1", sourceIndex: 1),
            .reserved(.add, sourceIndex: 2),
            .number("2", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .reserved(.mul, sourceIndex: 5),
            .number("3", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
        ]
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
