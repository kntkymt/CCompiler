import XCTest
@testable import Parser
import Tokenizer

final class ForTest: XCTestCase {

    func testFor() throws {
        let tokens: [Token] = [
            .keyword(.for, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 3),
            .number("1", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
            .number("2", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
            .number("3", sourceIndex: 8),
            .reserved(.parenthesisRight, sourceIndex: 9),
            .number("4", sourceIndex: 10),
            .reserved(.semicolon, sourceIndex: 11)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! ForStatementNode,
            ForStatementNode(
                token: tokens[0],
                condition: IntegerLiteralNode(token: tokens[4]),
                pre: IntegerLiteralNode(token: tokens[2]),
                post: IntegerLiteralNode(token: tokens[6]),
                body: IntegerLiteralNode(token: tokens[8]),
                sourceTokens: Array(tokens[0...9])
            )
        )
    }

    func testForBlock() throws {
        let tokens: [Token] = [
            .keyword(.for, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 3),
            .number("1", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
            .number("2", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
            .number("3", sourceIndex: 8),
            .reserved(.parenthesisRight, sourceIndex: 9),
            .reserved(.braceLeft, sourceIndex: 10),
            .number("4", sourceIndex: 10),
            .reserved(.semicolon, sourceIndex: 11),
            .number("5", sourceIndex: 12),
            .reserved(.semicolon, sourceIndex: 13),
            .reserved(.braceRight, sourceIndex: 14)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! ForStatementNode,
            ForStatementNode(
                token: tokens[0],
                condition: IntegerLiteralNode(token: tokens[4]),
                pre: IntegerLiteralNode(token: tokens[2]),
                post: IntegerLiteralNode(token: tokens[6]),
                body: BlockStatementNode(
                    statements: [
                        IntegerLiteralNode(token: tokens[9]),
                        IntegerLiteralNode(token: tokens[11]),
                    ],
                    sourceTokens: Array(tokens[8...13])
                ),
                sourceTokens: tokens
            )
        )
    }

    func testForNoNodes() throws {
        let tokens: [Token] = [
            .keyword(.for, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
            .reserved(.parenthesisRight, sourceIndex: 6),
            .number("4", sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! ForStatementNode,
            ForStatementNode(
                token: tokens[0],
                condition: nil,
                pre: nil,
                post: nil,
                body: IntegerLiteralNode(token: tokens[5]),
                sourceTokens: Array(tokens[0...6])
            )
        )
    }
}
