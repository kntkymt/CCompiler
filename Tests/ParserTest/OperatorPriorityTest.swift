import XCTest
@testable import Parser
@testable import AST
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: InfixOperatorExprSyntax(
                        left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                        operator: TokenSyntax(token: tokens[1]),
                        right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                    ),
                    operator: TokenSyntax(token: tokens[3]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4]))
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: InfixOperatorExprNode(
                    left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                    operator: .add,
                    right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
                ),
                operator: .add,
                right: IntegerLiteralNode(literal: tokens[4].text, sourceRange: tokens[4].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: InfixOperatorExprSyntax(
                        left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                        operator: TokenSyntax(token: tokens[1]),
                        right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                    ),
                    operator: TokenSyntax(token: tokens[3]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4]))
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: InfixOperatorExprNode(
                    left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                    operator: .mul,
                    right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
                ),
                operator: .mul,
                right: IntegerLiteralNode(literal: tokens[4].text, sourceRange: tokens[4].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: InfixOperatorExprSyntax(
                        left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                        operator: TokenSyntax(token: tokens[3]),
                        right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4]))
                    )
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .add,
                right: InfixOperatorExprNode(
                    left: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    operator: .mul,
                    right: IntegerLiteralNode(literal: tokens[4].text, sourceRange: tokens[4].sourceRange),
                    sourceRange: SourceRange(start: tokens[2].sourceRange.start, end: tokens[4].sourceRange.end)
                ),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: TupleExprSyntax(
                        parenthesisLeft: TokenSyntax(token: tokens[0]),
                        expression: InfixOperatorExprSyntax(
                            left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[1])),
                            operator: TokenSyntax(token: tokens[2]),
                            right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[3]))
                        ),
                        parenthesisRight: TokenSyntax(token: tokens[4])
                    ),
                    operator: TokenSyntax(token: tokens[5]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[6]))
                ),
                semicolon: TokenSyntax(token: tokens[7])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: TupleExprNode(
                    expression: InfixOperatorExprNode(
                        left: IntegerLiteralNode(literal: tokens[1].text, sourceRange: tokens[1].sourceRange),
                        operator: .add,
                        right: IntegerLiteralNode(literal: tokens[3].text, sourceRange: tokens[3].sourceRange),
                        sourceRange: SourceRange(start: tokens[1].sourceRange.start, end: tokens[3].sourceRange.end)
                    ),
                    sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
                ),
                operator: .add,
                right: IntegerLiteralNode(literal: tokens[6].text, sourceRange: tokens[6].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[6].sourceRange.end)
            )
        )
    }
}
