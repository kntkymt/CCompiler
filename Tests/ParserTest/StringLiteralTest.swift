import XCTest
@testable import Parser
import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral1() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .stringLiteral("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: StringLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                semicolon: TokenSyntax(token: tokens[1])
            )
        )
    }

    func testStringLiteral2() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .stringLiteral("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IdentifierSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: AssignSyntax(equal: TokenSyntax(token: tokens[1])),
                    right: StringLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )
    }
}
