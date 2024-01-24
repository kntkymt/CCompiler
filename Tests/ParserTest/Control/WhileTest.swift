import XCTest
@testable import Parser
import Tokenizer

final class WhileTest: XCTestCase {

    func testWhile() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .keyword(.while),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.parenthesisRight),
                .number("2"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: WhileStatementNode(
                    while: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    condition: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    parenthesisRight: TokenNode(token: tokens[3]),
                    body: BlockItemNode(
                        item: IntegerLiteralNode(literal: TokenNode(token: tokens[4])),
                        semicolon: TokenNode(token: tokens[5])
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
                        .number("1"),
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
