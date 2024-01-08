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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: WhileStatementNode(
                    whileToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    condition: IntegerLiteralNode(token: tokens[2]),
                    parenthesisRightToken: tokens[3],
                    body: BlockItemNode(
                        item: IntegerLiteralNode(token: tokens[4]),
                        semicolonToken: tokens[5]
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
                        .reserved(.semicolon)
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 9)))
        }
    }
}
