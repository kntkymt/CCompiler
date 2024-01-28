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
    }
}
