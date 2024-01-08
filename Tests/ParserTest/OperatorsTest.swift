import XCTest
@testable import Parser
import Tokenizer

final class OperatorsTest: XCTestCase {

    func testAdd() throws {
        let tokens: [Token] = [
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.add), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.sub), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.mul), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.div), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .reserved(.add), sourceIndex: 0),
            Token(kind: .number("1"), sourceIndex: 1),
            Token(kind: .reserved(.semicolon), sourceIndex: 2)
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
            Token(kind: .reserved(.sub), sourceIndex: 0),
            Token(kind: .number("1"), sourceIndex: 1),
            Token(kind: .reserved(.semicolon), sourceIndex: 2)
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
            Token(kind: .reserved(.and), sourceIndex: 0),
            Token(kind: .identifier("a"), sourceIndex: 1),
            Token(kind: .reserved(.semicolon), sourceIndex: 2)
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
            Token(kind: .reserved(.mul), sourceIndex: 0),
            Token(kind: .identifier("a"), sourceIndex: 1),
            Token(kind: .reserved(.semicolon), sourceIndex: 2)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.equal), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.notEqual), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.greaterThan), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.greaterThanOrEqual), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.lessThan), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
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
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.lessThanOrEqual), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4)
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
            Token(kind: .keyword(.sizeof), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 6),
            Token(kind: .number("1"), sourceIndex: 7),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 8),
            Token(kind: .reserved(.semicolon), sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: IntegerLiteralNode(token: Token(kind: .number("8"), sourceIndex: 6)),
                semicolonToken: tokens[4]
            )
        )
    }
}
