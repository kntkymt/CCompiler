import XCTest
@testable import Parser
import Tokenizer

final class WhileTest: XCTestCase {

    func testWhile() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.while),
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
                item: WhileStatementSyntax(
                    while: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    condition: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    parenthesisRight: TokenSyntax(token: tokens[3]),
                    body: BlockItemSyntax(
                        item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4])),
                        semicolon: TokenSyntax(token: tokens[5])
                    )
                )
            )
        )
    }

    func testWhileNoExpr() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .keyword(.while),
                        .reserved(.parenthesisLeft),
                        .integerLiteral("1"),
                        .reserved(.parenthesisRight),
                        .reserved(.semicolon),
                        .endOfFile
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 9)))
        }
    }
}
