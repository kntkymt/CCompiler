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
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! ReturnStatementNode,
            ReturnStatementNode(
                returnToken: tokens[0],
                expression: IntegerLiteralNode(token: tokens[1])
            )
        )
    }

    func testReturnNoExpr() throws {
        do {
            _ = try Parser(tokens: [
                .keyword(.return, sourceIndex: 0),
                .reserved(.semicolon, sourceIndex: 7),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 7))
        }
    }
}
