import XCTest
@testable import Parser
import Tokenizer

final class ForTest: XCTestCase {

    func testFor() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.semicolon),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .integerLiteral("3"),
                .reserved(.parenthesisRight),
                .integerLiteral("4"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: ForStatementSyntax(
                    for: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    pre: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    firstSemicolon: TokenSyntax(token: tokens[3]),
                    condition: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4])),
                    secondSemicolon: TokenSyntax(token: tokens[5]),
                    post: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[6])),
                    parenthesisRight: TokenSyntax(token: tokens[7]),
                    body: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[8])),
                        semicolon: TokenSyntax(token: tokens[9])
                    )
                )
            )
        )
    }

    func testForBlock() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.semicolon),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .integerLiteral("3"),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .integerLiteral("4"),
                .reserved(.semicolon),
                .integerLiteral("5"),
                .reserved(.semicolon),
                .reserved(.braceRight)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: ForStatementSyntax(
                    for: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    pre: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    firstSemicolon: TokenSyntax(token: tokens[3]),
                    condition: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4])),
                    secondSemicolon: TokenSyntax(token: tokens[5]),
                    post: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[6])),
                    parenthesisRight: TokenSyntax(token: tokens[7]),
                    body: BlockItemSyntax(
                        item: BlockStatementSyntax(
                            braceLeft: TokenSyntax(token: tokens[8]),
                            items: [
                                BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[9])), semicolon: TokenSyntax(token: tokens[10])),
                                BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[11])), semicolon: TokenSyntax(token: tokens[12]))
                            ],
                            braceRight: TokenSyntax(token: tokens[13])
                        )
                    )
                )
            )
        )
    }

    func testForNoSyntaxs() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.for),
                .reserved(.parenthesisLeft),
                .reserved(.semicolon),
                .reserved(.semicolon),
                .reserved(.parenthesisRight),
                .integerLiteral("4"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: ForStatementSyntax(
                    for: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    pre: nil,
                    firstSemicolon: TokenSyntax(token: tokens[2]),
                    condition: nil,
                    secondSemicolon: TokenSyntax(token: tokens[3]),
                    post: nil,
                    parenthesisRight: TokenSyntax(token: tokens[4]),
                    body: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[5])),
                        semicolon: TokenSyntax(token: tokens[6])
                    )
                )
            )
        )
    }
}
