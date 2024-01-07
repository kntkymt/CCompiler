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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: tokens[0],
                    expression: IntegerLiteralNode(token: tokens[1])
                ),
                semicolonToken: tokens[2]
            )
        )
    }

    func testUnarySub() throws {
        let tokens: [Token] = [
            .reserved(.sub, sourceIndex: 0),
            .number("1", sourceIndex: 1),
            .reserved(.semicolon, sourceIndex: 2)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: tokens[0],
                    expression: IntegerLiteralNode(token: tokens[1])
                ),
                semicolonToken: tokens[2]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: tokens[0],
                    expression: IdentifierNode(token: tokens[1])
                ),
                semicolonToken: tokens[2]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: tokens[0],
                    expression: IdentifierNode(token: tokens[1])
                ),
                semicolonToken: tokens[2]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
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

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: BinaryOperatorNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }

    // FIXME: sizeofって本当にAST上で置き換えるの？
    func testSizeof() throws {
        let tokens: [Token] = [
            .keyword(.sizeof, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 6),
            .number("1", sourceIndex: 7),
            .reserved(.parenthesisRight, sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: IntegerLiteralNode(token: .number("8", sourceIndex: 6)),
                semicolonToken: tokens[4]
            )
        )
    }
}
