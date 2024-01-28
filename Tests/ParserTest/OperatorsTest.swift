import XCTest
@testable import Parser
import Tokenizer

final class OperatorsTest: XCTestCase {

    func testAdd() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.add),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testSub() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.sub),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testMul() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.mul),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testDiv() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.div),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testUnaryAdd() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.add),
                .integerLiteral("1"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: PrefixOperatorExprSyntax(
                    operator: TokenSyntax(token: tokens[0]),
                    expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[1]))
                ),
                semicolon: TokenSyntax(token: tokens[2])
            )
        )
    }

    func testUnarySub() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .reserved(.sub),
                .integerLiteral("1"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: PrefixOperatorExprSyntax(
                    operator: TokenSyntax(token: tokens[0]),
                    expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[1]))
                ),
                semicolon: TokenSyntax(token: tokens[2])
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: PrefixOperatorExprSyntax(
                    operator: TokenSyntax(token: tokens[0]),
                    expression: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[1]))
                ),
                semicolon: TokenSyntax(token: tokens[2])
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: PrefixOperatorExprSyntax(
                    operator: TokenSyntax(token: tokens[0]),
                    expression: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[1]))
                ),
                semicolon: TokenSyntax(token: tokens[2])
            )
        )
    }

    func testEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.equal),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testNotEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.notEqual),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testGreaterThan() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.greaterThan),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testGreaterThanOrEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.greaterThanOrEqual),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testLessThan() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.lessThan),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testLessThanOrEqual() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.lessThanOrEqual),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    // FIXME: sizeofって本当にAST上で置き換えるの？
    func testSizeof() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.sizeof),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.parenthesisRight),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: PrefixOperatorExprSyntax(
                    operator: TokenSyntax(token: tokens[0]),
                    expression: TupleExprSyntax(
                        parenthesisLeft: TokenSyntax(token: tokens[1]),
                        expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                        parenthesisRight: TokenSyntax(token: tokens[3])
                    )
                ),
                semicolon: TokenSyntax(token: tokens[4])
            )
        )
    }
}
