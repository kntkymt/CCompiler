import XCTest
@testable import Parser
import Tokenizer

final class FunctionTest: XCTestCase {

    func testFunctionDecl() throws {
        let tokens: [Token] = [
            .identifier("hoge", sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 4),
            .reserved(.parenthesisRight, sourceIndex: 5),
            .reserved(.braceLeft, sourceIndex: 6),
            .number("1", sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8),
            .number("2", sourceIndex: 9),
            .reserved(.semicolon, sourceIndex: 10),
            .reserved(.braceRight, sourceIndex: 11)
        ]
        let node = try Parser(tokens: tokens).functionDecl()

        XCTAssertEqual(
            node,
            FunctionDeclNode(
                functionName: tokens[0],
                block: BlockStatementNode(
                    statements: [
                        IntegerLiteralNode(token: tokens[4]),
                        IntegerLiteralNode(token: tokens[6])
                    ],
                    sourceTokens: Array(tokens[3...8])
                ),
                sourceTokens: tokens
            )
        )
    }

    func testFunctionDecls() throws {
        let tokens: [Token] = [
            .identifier("hoge", sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 4),
            .reserved(.parenthesisRight, sourceIndex: 5),
            .reserved(.braceLeft, sourceIndex: 6),
            .number("1", sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8),
            .reserved(.braceRight, sourceIndex: 9),
            .identifier("fuga", sourceIndex: 10),
            .reserved(.parenthesisLeft, sourceIndex: 14),
            .reserved(.parenthesisRight, sourceIndex: 15),
            .reserved(.braceLeft, sourceIndex: 16),
            .number("1", sourceIndex: 17),
            .reserved(.semicolon, sourceIndex: 18),
            .reserved(.braceRight, sourceIndex: 19)
        ]
        let nodes = try Parser(tokens: tokens).parse()

        XCTAssertEqual(
            nodes,
            [
                FunctionDeclNode(
                    functionName: tokens[0],
                    block: BlockStatementNode(
                        statements: [
                            IntegerLiteralNode(token: tokens[4])
                        ],
                        sourceTokens: Array(tokens[3...6])
                    ),
                    sourceTokens: Array(tokens[0...6])
                ),
                FunctionDeclNode(
                    functionName: tokens[7],
                    block: BlockStatementNode(
                        statements: [
                            IntegerLiteralNode(token: tokens[11])
                        ],
                        sourceTokens: Array(tokens[10...13])
                    ),
                    sourceTokens: Array(tokens[7...13])
                )
            ]
        )
    }
}
