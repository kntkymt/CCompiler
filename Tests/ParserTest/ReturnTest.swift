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
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: ReturnStatementNode(
                    return: TokenNode(token: tokens[0]),
                    expression: IntegerLiteralNode(literal: TokenNode(token: tokens[1]))
                ),
                semicolon: TokenNode(token: tokens[2])
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
