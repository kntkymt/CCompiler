import XCTest
@testable import Parser
import Tokenizer

final class ReturnTest: XCTestCase {

    func testReturn() throws {
        let tokens: [Token] = [
            .keyword(.return, sourceIndex: 0),
            .number("2", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
        ]
        let node = try parse(tokens: tokens)[0]

        XCTAssertEqual(
            node as! ReturnStatementNode,
            ReturnStatementNode(
                token: tokens[0],
                expression: IntegerLiteralNode(token: tokens[1]),
                sourceTokens: Array(tokens[0...1])
            )
        )
    }

    func testReturnNoExpr() throws {
        do {
            _ = try parse(tokens: [
                .keyword(.return, sourceIndex: 0),
                .reserved(.semicolon, sourceIndex: 7),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 7))
        }
    }
}
