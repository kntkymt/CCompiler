import XCTest
@testable import Parser
import Tokenizer

final class OperatorsTest: XCTestCase {

    func testAdd() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testSub() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.sub, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testMul() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.mul, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testDiv() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.div, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testUnaryAdd() throws {
        let tokens: [Token] = [
            .reserved(.add, sourceIndex: 0),
            .number("1", sourceIndex: 1),
            .reserved(.semicolon, sourceIndex: 2)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! IntegerLiteralNode,
            IntegerLiteralNode(token: tokens[1])
        )
    }

    func testUnarySub() throws {
        let tokens: [Token] = [
            .reserved(.sub, sourceIndex: 0),
            .number("1", sourceIndex: 1),
            .reserved(.semicolon, sourceIndex: 2)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[0]),
                left: IntegerLiteralNode(token: .number("0", sourceIndex: 1)),
                right: IntegerLiteralNode(token: tokens[1]),
                sourceTokens: Array(tokens[0...1])
            )
        )
    }

    func testUnaryAddress() throws {
        let tokens: [Token] = [
            .reserved(.and, sourceIndex: 0),
            .identifier("a", sourceIndex: 1),
            .reserved(.semicolon, sourceIndex: 2)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! PrefixOperatorExpressionNode,
            PrefixOperatorExpressionNode(
                operator: tokens[0],
                right: IdentifierNode(token: tokens[1]),
                sourceTokens: Array(tokens[0...1])
            )
        )
    }

    func testUnaryReference() throws {
        let tokens: [Token] = [
            .reserved(.mul, sourceIndex: 0),
            .identifier("a", sourceIndex: 1),
            .reserved(.semicolon, sourceIndex: 2)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! PrefixOperatorExpressionNode,
            PrefixOperatorExpressionNode(
                operator: tokens[0],
                right: IdentifierNode(token: tokens[1]),
                sourceTokens: Array(tokens[0...1])
            )
        )
    }

    func testEqual() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.equal, sourceIndex: 1),
            .number("2", sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testNotEqual() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.notEqual, sourceIndex: 1),
            .number("2", sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testGreaterThan() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.greaterThan, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testGreaterThanOrEqual() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.greaterThanOrEqual, sourceIndex: 1),
            .number("2", sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testLessThan() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.lessThan, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testLessThanOrEqual() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.lessThanOrEqual, sourceIndex: 1),
            .number("2", sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testSizeof() throws {
        let tokens: [Token] = [
            .keyword(.sizeOf, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 6),
            .number("1", sourceIndex: 7),
            .reserved(.parenthesisRight, sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! IntegerLiteralNode,
            IntegerLiteralNode(token: .number("8", sourceIndex: 7))
        )
    }
}
