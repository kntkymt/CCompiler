import XCTest
@testable import Parser
import Tokenizer

final class OperatorsTest: XCTestCase {

    func testAdd() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.add),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testSub() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.sub),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testMul() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.mul),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testDiv() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.div),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testUnaryAdd() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.add),
                .number("1"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: TokenNode(token: tokens[0]),
                    expression: IntegerLiteralNode(literal: TokenNode(token: tokens[1]))
                ),
                semicolon: TokenNode(token: tokens[2])
            )
        )
    }

    func testUnarySub() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.sub),
                .number("1"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: TokenNode(token: tokens[0]),
                    expression: IntegerLiteralNode(literal: TokenNode(token: tokens[1]))
                ),
                semicolon: TokenNode(token: tokens[2])
            )
        )
    }

    func testUnaryAddress() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.and),
                .identifier("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: TokenNode(token: tokens[0]),
                    expression: IdentifierNode(baseName: TokenNode(token: tokens[1]))
                ),
                semicolon: TokenNode(token: tokens[2])
            )
        )
    }

    func testUnaryReference() throws {
        let tokens: [Token] = buildTokens(
                kinds: [
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: TokenNode(token: tokens[0]),
                    expression: IdentifierNode(baseName: TokenNode(token: tokens[1]))
                ),
                semicolon: TokenNode(token: tokens[2])
            )
        )
    }

    func testEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.equal),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testNotEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.notEqual),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testGreaterThan() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.greaterThan),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testGreaterThanOrEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.greaterThanOrEqual),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testLessThan() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.lessThan),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    func testLessThanOrEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .number("1"),
                .reserved(.lessThanOrEqual),
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
                    left: IntegerLiteralNode(literal: TokenNode(token: tokens[0])),
                    operator: BinaryOperatorNode(operator: TokenNode(token: tokens[1])),
                    right: IntegerLiteralNode(literal: TokenNode(token: tokens[2]))
                ),
                semicolon: TokenNode(token: tokens[3])
            )
        )
    }

    // FIXME: sizeofって本当にAST上で置き換えるの？
    func testSizeof() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.sizeof),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.parenthesisRight),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: PrefixOperatorExpressionNode(
                    operator: TokenNode(token: tokens[0]),
                    expression: TupleExpressionNode(
                        parenthesisLeft: TokenNode(token: tokens[1]),
                        expression: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                        parenthesisRight: TokenNode(token: tokens[3])
                    )
                ),
                semicolon: TokenNode(token: tokens[4])
            )
        )
    }
}
