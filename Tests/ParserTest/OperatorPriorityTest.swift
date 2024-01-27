import XCTest
@testable import Parser
import Tokenizer

final class OperatorPriorityTest: XCTestCase {

    func testAddPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.add),
                .integerLiteral("2"),
                .reserved(.add),
                .integerLiteral("3"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                        operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                        right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                    ),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[3])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[4]))
                ),
                semicolon: TokenNode(token: tokens[5])
            )
        )
    }

    func testMulPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.mul),
                .integerLiteral("2"),
                .reserved(.mul),
                .integerLiteral("3"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                        operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                        right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                    ),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[3])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[4]))
                ),
                semicolon: TokenNode(token: tokens[5])
            )
        )
    }

    func testAddAndMulPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.add),
                .integerLiteral("2"),
                .reserved(.mul),
                .integerLiteral("3"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                        operator: BinaryOperatorNode(operator: TokenNode(token: tokens[3])),
                        right: IntegerLiteralNode(literal: TokenNode(token: tokens[4]))
                    )
                ),
                semicolon: TokenNode(token: tokens[5])
            )
        )
    }

    func testParenthesisPriority() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.add),
                .integerLiteral("2"),
                .reserved(.parenthesisRight),
                .reserved(.mul),
                .integerLiteral("3"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: TupleExpressionNode(
                        parenthesisLeft: TokenNode(token: tokens[0]),
                        expression: InfixOperatorExpressionNode(
                            left: IntegerLiteralNode(literal: TokenNode(token: tokens[1])),
                            operator: BinaryOperatorNode(operator: TokenNode(token: tokens[2])),
                            right: IntegerLiteralNode(literal: TokenNode(token: tokens[3]))
                        ),
                        parenthesisRight: TokenNode(token: tokens[4])
                    ),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[5])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[6]))
                ),
                semicolon: TokenNode(token: tokens[7])
            )
        )
    }
}
