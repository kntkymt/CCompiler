import XCTest
@testable import Parser
import Tokenizer

final class FunctionTest: XCTestCase {

    func testFunctionDecl() throws {
        let tokens: [Token] = [
            Token(kind: .type(.int), sourceIndex: 0),
            Token(kind: .identifier("main"), sourceIndex: 4),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 8),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 9),
            Token(kind: .reserved(.braceLeft), sourceIndex: 10),
            Token(kind: .number("1"), sourceIndex: 11),
            Token(kind: .reserved(.semicolon), sourceIndex: 12),
            Token(kind: .number("2"), sourceIndex: 13),
            Token(kind: .reserved(.semicolon), sourceIndex: 14),
            Token(kind: .reserved(.braceRight), sourceIndex: 15)
        ]
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnTypeNode: TypeNode(typeToken: tokens[0]),
                            functionNameToken: tokens[1],
                            parenthesisLeftToken: tokens[2],
                            parameterNodes: [],
                            parenthesisRightToken: tokens[3],
                            block: BlockStatementNode(
                                braceLeftToken: tokens[4],
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[5]), semicolonToken: tokens[6]),
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[7]), semicolonToken: tokens[8]),
                                ],
                                braceRightToken: tokens[9]
                            )
                        )
                    )
                ]
            )
        )
    }

    func testFunctionDeclPointer() throws {
        let tokens: [Token] = [
            Token(kind: .type(.int), sourceIndex: 0),
            Token(kind: .reserved(.mul), sourceIndex: 3),
            Token(kind: .identifier("main"), sourceIndex: 5),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 9),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 10),
            Token(kind: .reserved(.braceLeft), sourceIndex: 11),
            Token(kind: .number("1"), sourceIndex: 12),
            Token(kind: .reserved(.semicolon), sourceIndex: 13),
            Token(kind: .number("2"), sourceIndex: 14),
            Token(kind: .reserved(.semicolon), sourceIndex: 15),
            Token(kind: .reserved(.braceRight), sourceIndex: 16)
        ]
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnTypeNode: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]),
                            functionNameToken: tokens[2],
                            parenthesisLeftToken: tokens[3],
                            parameterNodes: [],
                            parenthesisRightToken: tokens[4],
                            block: BlockStatementNode(
                                braceLeftToken: tokens[5],
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[6]), semicolonToken: tokens[7]),
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[8]), semicolonToken: tokens[9]),
                                ],
                                braceRightToken: tokens[10]
                            )
                        )
                    )
                ]
            )
        )
    }

    func testFunctionCall() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("main"), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 4),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 5),
            Token(kind: .reserved(.semicolon), sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: FunctionCallExpressionNode(
                    identifierToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    arguments: [],
                    parenthesisRightToken: tokens[2]
                ),
                semicolonToken: tokens[3]
            )
        )
    }

    func testFunctionDeclWithParameter() throws {
        let tokens: [Token] = [
            Token(kind: .type(.int), sourceIndex: 0),
            Token(kind: .identifier("main"), sourceIndex: 4),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 8),
            Token(kind: .type(.int), sourceIndex: 9),
            Token(kind: .identifier("a"), sourceIndex: 13),
            Token(kind: .reserved(.comma), sourceIndex: 14),
            Token(kind: .type(.int), sourceIndex: 15),
            Token(kind: .identifier("b"), sourceIndex: 19),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 20),
            Token(kind: .reserved(.braceLeft), sourceIndex: 21),
            Token(kind: .number("1"), sourceIndex: 22),
            Token(kind: .reserved(.semicolon), sourceIndex: 23),
            Token(kind: .reserved(.braceRight), sourceIndex: 24)
        ]
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnTypeNode: TypeNode(typeToken: tokens[0]),
                            functionNameToken: tokens[1],
                            parenthesisLeftToken: tokens[2],
                            parameterNodes: [
                                FunctionParameterNode(type: TypeNode(typeToken: tokens[3]), identifierToken: tokens[4], commaToken: tokens[5]),
                                FunctionParameterNode(type: TypeNode(typeToken: tokens[6]), identifierToken: tokens[7])
                            ],
                            parenthesisRightToken: tokens[8],
                            block: BlockStatementNode(
                                braceLeftToken: tokens[9],
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[10]), semicolonToken: tokens[11]),
                                ],
                                braceRightToken: tokens[12]
                            )
                        )
                    )
                ]
            )
        )
    }

    func testFunctionCallWithArguments() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("main"), sourceIndex: 0),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 4),
            Token(kind: .number("1"), sourceIndex: 5),
            Token(kind: .reserved(.comma), sourceIndex: 6),
            Token(kind: .identifier("a"), sourceIndex: 7),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 8),
            Token(kind: .reserved(.semicolon), sourceIndex: 9)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: FunctionCallExpressionNode(
                    identifierToken: tokens[0],
                    parenthesisLeftToken: tokens[1],
                    arguments: [
                        ExpressionListItemNode(
                            expression: IntegerLiteralNode(token: tokens[2]),
                            comma: tokens[3]
                        ),
                        ExpressionListItemNode(expression: IdentifierNode(token: tokens[4]))
                    ],
                    parenthesisRightToken: tokens[5]
                ),
                semicolonToken: tokens[6]
            )
        )
    }

    func testFunctionDecls() throws {
        let tokens: [Token] = [
            Token(kind: .type(.int), sourceIndex: 0),
            Token(kind: .identifier("main"), sourceIndex: 4),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 8),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 9),
            Token(kind: .reserved(.braceLeft), sourceIndex: 10),
            Token(kind: .number("1"), sourceIndex: 11),
            Token(kind: .reserved(.semicolon), sourceIndex: 12),
            Token(kind: .reserved(.braceRight), sourceIndex: 13),
            Token(kind: .type(.int), sourceIndex: 14),
            Token(kind: .identifier("fuga"), sourceIndex: 18),
            Token(kind: .reserved(.parenthesisLeft), sourceIndex: 22),
            Token(kind: .reserved(.parenthesisRight), sourceIndex: 23),
            Token(kind: .reserved(.braceLeft), sourceIndex: 24),
            Token(kind: .number("1"), sourceIndex: 25),
            Token(kind: .reserved(.semicolon), sourceIndex: 26),
            Token(kind: .reserved(.braceRight), sourceIndex: 27)
        ]
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnTypeNode: TypeNode(typeToken: tokens[0]),
                            functionNameToken: tokens[1],
                            parenthesisLeftToken: tokens[2],
                            parameterNodes: [],
                            parenthesisRightToken: tokens[3],
                            block: BlockStatementNode(
                                braceLeftToken: tokens[4],
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[5]), semicolonToken: tokens[6])
                                ],
                                braceRightToken: tokens[7]
                            )
                        )
                    ),
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnTypeNode: TypeNode(typeToken: tokens[8]),
                            functionNameToken: tokens[9],
                            parenthesisLeftToken: tokens[10],
                            parameterNodes: [],
                            parenthesisRightToken: tokens[11],
                            block: BlockStatementNode(
                                braceLeftToken: tokens[12],
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(token: tokens[13]), semicolonToken: tokens[14])
                                ],
                                braceRightToken: tokens[15]
                            )
                        )
                    )
                ]
            )
        )
    }

    func testSubscriptCall() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("a"), sourceIndex: 0),
            Token(kind: .reserved(.squareLeft), sourceIndex: 1),
            Token(kind: .number("1"), sourceIndex: 2),
            Token(kind: .reserved(.squareRight), sourceIndex: 3),
            Token(kind: .reserved(.semicolon), sourceIndex: 4)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: SubscriptCallExpressionNode(
                    identifierNode: IdentifierNode(token: tokens[0]),
                    squareLeftToken: tokens[1],
                    argument: IntegerLiteralNode(token: tokens[2]),
                    squareRightToken: tokens[3]
                ),
                semicolonToken: tokens[4]
            )
        )
    }

    func testSubscriptCall2() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("a"), sourceIndex: 0),
            Token(kind: .reserved(.squareLeft), sourceIndex: 1),
            Token(kind: .number("1"), sourceIndex: 2),
            Token(kind: .reserved(.add), sourceIndex: 3),
            Token(kind: .identifier("b"), sourceIndex: 4),
            Token(kind: .reserved(.squareRight), sourceIndex: 5),
            Token(kind: .reserved(.semicolon), sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: SubscriptCallExpressionNode(
                    identifierNode: IdentifierNode(token: tokens[0]),
                    squareLeftToken: tokens[1],
                    argument: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(token: tokens[2]),
                        operator: BinaryOperatorNode(token: tokens[3]),
                        right: IdentifierNode(token: tokens[4])
                    ),
                    squareRightToken: tokens[5]
                ),
                semicolonToken: tokens[6]
            )
        )
    }
}
