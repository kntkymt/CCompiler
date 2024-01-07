import XCTest
@testable import Parser
import Tokenizer

final class IfTest: XCTestCase {

    func testIf() throws {
        let tokens: [Token] = [
            .keyword(.if, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 2),
            .number("1", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .number("2", sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! IfStatementNode,
            IfStatementNode(
                ifToken: tokens[0],
                condition: IntegerLiteralNode(token: tokens[2]),
                trueBody: IntegerLiteralNode(token: tokens[4]),
                elseToken: nil,
                falseBody: nil
            )
        )
    }

    func testIfElse() throws {
        let tokens: [Token] = [
            .keyword(.if, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 2),
            .number("1", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .number("2", sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6),
            .keyword(.else, sourceIndex: 7),
            .number("3", sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! IfStatementNode,
            IfStatementNode(
                ifToken: tokens[0],
                condition: IntegerLiteralNode(token: tokens[2]),
                trueBody: IntegerLiteralNode(token: tokens[4]),
                elseToken: tokens[6],
                falseBody: IntegerLiteralNode(token: tokens[7])
            )
        )
    }
}
