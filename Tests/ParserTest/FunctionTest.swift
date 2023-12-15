import XCTest
@testable import Parser
import Tokenizer

final class FunctionTest: XCTestCase {

    func testFunctionDecl() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .identifier("main", sourceIndex: 4),
            .reserved(.parenthesisLeft, sourceIndex: 8),
            .reserved(.parenthesisRight, sourceIndex: 9),
            .reserved(.braceLeft, sourceIndex: 10),
            .number("1", sourceIndex: 11),
            .reserved(.semicolon, sourceIndex: 12),
            .number("2", sourceIndex: 13),
            .reserved(.semicolon, sourceIndex: 14),
            .reserved(.braceRight, sourceIndex: 15)
        ]
        let node = try Parser(tokens: tokens).functionDecl()

        XCTAssertEqual(
            node,
            FunctionDeclNode(
                returnType: TypeNode(typeToken: tokens[0]),
                token: tokens[1],
                block: BlockStatementNode(
                    statements: [
                        IntegerLiteralNode(token: tokens[5]),
                        IntegerLiteralNode(token: tokens[7])
                    ],
                    sourceTokens: Array(tokens[4...9])
                ),
                parameters: [],
                sourceTokens: tokens
            )
        )
    }

    func testFunctionDeclPointer() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .reserved(.mul, sourceIndex: 3),
            .identifier("main", sourceIndex: 5),
            .reserved(.parenthesisLeft, sourceIndex: 9),
            .reserved(.parenthesisRight, sourceIndex: 10),
            .reserved(.braceLeft, sourceIndex: 11),
            .number("1", sourceIndex: 12),
            .reserved(.semicolon, sourceIndex: 13),
            .number("2", sourceIndex: 14),
            .reserved(.semicolon, sourceIndex: 15),
            .reserved(.braceRight, sourceIndex: 16)
        ]
        let node = try Parser(tokens: tokens).functionDecl()

        XCTAssertEqual(
            node,
            FunctionDeclNode(
                returnType: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]),
                token: tokens[2],
                block: BlockStatementNode(
                    statements: [
                        IntegerLiteralNode(token: tokens[6]),
                        IntegerLiteralNode(token: tokens[8])
                    ],
                    sourceTokens: Array(tokens[5...10])
                ),
                parameters: [],
                sourceTokens: tokens
            )
        )
    }

    func testFunctionCall() throws {
        let tokens: [Token] = [
            .identifier("main", sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 4),
            .reserved(.parenthesisRight, sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! FunctionCallExpressionNode,
            FunctionCallExpressionNode(token: tokens[0], arguments: [], sourceTokens: Array(tokens[0...2]))
        )
    }

    func testFunctionDeclWithParameter() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .identifier("main", sourceIndex: 4),
            .reserved(.parenthesisLeft, sourceIndex: 8),
            .type(.int, sourceIndex: 9),
            .identifier("a", sourceIndex: 13),
            .reserved(.comma, sourceIndex: 14),
            .type(.int, sourceIndex: 15),
            .identifier("b", sourceIndex: 19),
            .reserved(.parenthesisRight, sourceIndex: 20),
            .reserved(.braceLeft, sourceIndex: 21),
            .number("1", sourceIndex: 22),
            .reserved(.semicolon, sourceIndex: 23),
            .reserved(.braceRight, sourceIndex: 24)
        ]
        let node = try Parser(tokens: tokens).functionDecl()

        XCTAssertEqual(
            node,
            FunctionDeclNode(
                returnType: TypeNode(typeToken: tokens[0]),
                token: tokens[1],
                block: BlockStatementNode(
                    statements: [
                        IntegerLiteralNode(token: tokens[10])
                    ],
                    sourceTokens: Array(tokens[9...12])
                ),
                parameters: [
                    VariableDeclNode(type: TypeNode(typeToken: tokens[3]), identifierToken: tokens[4]),
                    VariableDeclNode(type: TypeNode(typeToken: tokens[6]), identifierToken: tokens[7])
                ],
                sourceTokens: tokens
            )
        )
    }

    func testFunctionCallWithArguments() throws {
        let tokens: [Token] = [
            .identifier("main", sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 4),
            .number("1", sourceIndex: 5),
            .reserved(.comma, sourceIndex: 6),
            .identifier("a", sourceIndex: 7),
            .reserved(.parenthesisRight, sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! FunctionCallExpressionNode,
            FunctionCallExpressionNode(
                token: tokens[0], 
                arguments: [
                    IntegerLiteralNode(token: tokens[2]),
                    IdentifierNode(token: tokens[4])
                ],
                sourceTokens: Array(tokens[0...5])
            )
        )
    }

    func testFunctionDecls() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .identifier("main", sourceIndex: 4),
            .reserved(.parenthesisLeft, sourceIndex: 8),
            .reserved(.parenthesisRight, sourceIndex: 9),
            .reserved(.braceLeft, sourceIndex: 10),
            .number("1", sourceIndex: 11),
            .reserved(.semicolon, sourceIndex: 12),
            .reserved(.braceRight, sourceIndex: 13),
            .type(.int, sourceIndex: 14),
            .identifier("fuga", sourceIndex: 18),
            .reserved(.parenthesisLeft, sourceIndex: 22),
            .reserved(.parenthesisRight, sourceIndex: 23),
            .reserved(.braceLeft, sourceIndex: 24),
            .number("1", sourceIndex: 25),
            .reserved(.semicolon, sourceIndex: 26),
            .reserved(.braceRight, sourceIndex: 27)
        ]
        let nodes = try Parser(tokens: tokens).parse()

        XCTAssertEqual(
            nodes,
            SourceFileNode(
                functions: [
                    FunctionDeclNode(
                        returnType: TypeNode(typeToken: tokens[0]),
                        token: tokens[1],
                        block: BlockStatementNode(
                            statements: [
                                IntegerLiteralNode(token: tokens[5])
                            ],
                            sourceTokens: Array(tokens[4...7])
                        ),
                        parameters: [],
                        sourceTokens: Array(tokens[0...7])
                    ),
                    FunctionDeclNode(
                        returnType: TypeNode(typeToken: tokens[8]),
                        token: tokens[9],
                        block: BlockStatementNode(
                            statements: [
                                IntegerLiteralNode(token: tokens[13])
                            ],
                            sourceTokens: Array(tokens[12...15])
                        ),
                        parameters: [],
                        sourceTokens: Array(tokens[8...15])
                    )
                ],
                sourceTokens: tokens
            )
        )
    }

    func testSubscriptCall() throws {
        let tokens: [Token] = [
            .identifier("a", sourceIndex: 0),
            .reserved(.squareLeft, sourceIndex: 1),
            .number("1", sourceIndex: 2),
            .reserved(.squareRight, sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! SubscriptCallExpressionNode,
            SubscriptCallExpressionNode(
                identifierToken: tokens[0],
                squareLeftToken: tokens[1],
                argument: IntegerLiteralNode(token: tokens[2]),
                squareRightToken: tokens[3]
            )
        )
    }

    func testSubscriptCall2() throws {
        let tokens: [Token] = [
            .identifier("a", sourceIndex: 0),
            .reserved(.squareLeft, sourceIndex: 1),
            .number("1", sourceIndex: 2),
            .reserved(.add, sourceIndex: 3),
            .identifier("b", sourceIndex: 4),
            .reserved(.squareRight, sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! SubscriptCallExpressionNode,
            SubscriptCallExpressionNode(
                identifierToken: tokens[0],
                squareLeftToken: tokens[1],
                argument: InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: tokens[3]),
                    left: IntegerLiteralNode(token: tokens[2]),
                    right: IdentifierNode(token: tokens[4]),
                    sourceTokens: Array(tokens[2...4])
                ),
                squareRightToken: tokens[5]
            )
        )
    }
}
