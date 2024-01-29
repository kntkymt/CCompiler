import XCTest
@testable import Parser
@testable import AST
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

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! ReturnStatementNode,
            ReturnStatementNode(
                expression: IntegerLiteralNode(literal: tokens[1].text, sourceRange: tokens[1].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
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
