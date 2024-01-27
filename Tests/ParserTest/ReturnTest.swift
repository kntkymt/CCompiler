import XCTest
@testable import Parser
import Tokenizer

final class ReturnTest: XCTestCase {

    func testReturn() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.return),
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
                item: ReturnStatementSyntax(
                    return: TokenSyntax(token: tokens[0]),
                    expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[1]))
                ),
                semicolon: TokenSyntax(token: tokens[2])
            )
        )
    }

    func testReturnNoExpr() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .keyword(.return),
                        .reserved(.semicolon),
                        .endOfFile
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 7)))
        }
    }
}
