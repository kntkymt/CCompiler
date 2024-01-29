import XCTest
@testable import Parser
@testable import AST
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .add,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .sub,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .mul,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .div,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! PrefixOperatorExprNode,
            PrefixOperatorExprNode(
                operator: .plus,
                expression: IntegerLiteralNode(literal: tokens[1].text, sourceRange: tokens[1].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! PrefixOperatorExprNode,
            PrefixOperatorExprNode(
                operator: .minus,
                expression: IntegerLiteralNode(literal: tokens[1].text, sourceRange: tokens[1].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! PrefixOperatorExprNode,
            PrefixOperatorExprNode(
                operator: .address,
                expression: DeclReferenceNode(baseName: tokens[1].text, sourceRange: tokens[1].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! PrefixOperatorExprNode,
            PrefixOperatorExprNode(
                operator: .reference,
                expression: DeclReferenceNode(baseName: tokens[1].text, sourceRange: tokens[1].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .equal,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .notEqual,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .greaterThan,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .greaterThanOrEqual,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .lessThanOrEqual,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
            )
        )
    }

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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! PrefixOperatorExprNode,
            PrefixOperatorExprNode(
                operator: .sizeof,
                expression: TupleExprNode(
                    expression: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    sourceRange: SourceRange(start: tokens[1].sourceRange.start, end: tokens[3].sourceRange.end)
                ),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[3].sourceRange.end)
            )
        )
    }
}
