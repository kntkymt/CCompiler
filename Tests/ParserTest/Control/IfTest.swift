import XCTest
@testable import Parser
import Tokenizer

final class IfTest: XCTestCase {

    func testIf() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.if),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.parenthesisRight),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: IfStatementSyntax(
                    if: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    condition: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    parenthesisRight: TokenSyntax(token: tokens[3]),
                    trueBody: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4])),
                        semicolon: TokenSyntax(token: tokens[5])
                    ),
                    else: nil,
                    falseBody: nil
                )
            )
        )
    }

    func testIfElse() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.if),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
                .reserved(.parenthesisRight),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .keyword(.else),
                .integerLiteral("3"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: IfStatementSyntax(
                    if: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    condition: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    parenthesisRight: TokenSyntax(token: tokens[3]),
                    trueBody: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4])),
                        semicolon: TokenSyntax(token: tokens[5])
                    ),
                    else: TokenSyntax(token: tokens[6]),
                    falseBody: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[7])),
                        semicolon: TokenSyntax(token: tokens[8])
                    )
                )
            )
        )
    }
}
