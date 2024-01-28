import XCTest
@testable import Parser
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
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
                    left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }

    func testAssignTo2Var() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .identifier("b"),
                .reserved(.assign),
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
                    left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: InfixOperatorExprSyntax(
                        left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[2])),
                        operator: TokenSyntax(token: tokens[3]),
                        right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4]))
                    )
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.assign),
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
}
