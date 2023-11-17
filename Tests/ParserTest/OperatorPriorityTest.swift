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
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[3]),
                left: InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: tokens[1]),
                    left: IntegerLiteralNode(token: tokens[0]),
                    right: IntegerLiteralNode(token: tokens[2]),
                    sourceTokens: Array(tokens[0...2])
                ),
                right: IntegerLiteralNode(token: tokens[4]),
                sourceTokens: Array(tokens[0...4])
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
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[3]),
                left: InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: tokens[1]),
                    left: IntegerLiteralNode(token: tokens[0]),
                    right: IntegerLiteralNode(token: tokens[2]),
                    sourceTokens: Array(tokens[0...2])
                ),
                right: IntegerLiteralNode(token: tokens[4]),
                sourceTokens: Array(tokens[0...4])
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
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: tokens[3]),
                    left: IntegerLiteralNode(token: tokens[2]),
                    right: IntegerLiteralNode(token: tokens[4]),
                    sourceTokens: Array(tokens[2...4])
                ),
                sourceTokens: Array(tokens[0...4])
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
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[5]),
                left: InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: tokens[2]),
                    left: IntegerLiteralNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[3]), 
                    sourceTokens: Array(tokens[1...3])
                ),
                right: IntegerLiteralNode(token: tokens[6]),
                sourceTokens: Array(tokens[0...6])
            )
        )
    }
}
