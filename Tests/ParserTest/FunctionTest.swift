import XCTest
@testable import Parser
import Tokenizer

final class FunctionTest: XCTestCase {

    func testFunctionDecl() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.semicolon),
                .number("2"),
                .reserved(.semicolon),
                .reserved(.braceRight)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.semicolon),
                .number("2"),
                .reserved(.semicolon),
                .reserved(.braceRight)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.semicolon)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .type(.int),
                .identifier("a"),
                .reserved(.comma),
                .type(.int),
                .identifier("b"),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.semicolon),
                .reserved(.braceRight)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .number("1"),
                .reserved(.comma),
                .identifier("a"),
                .reserved(.parenthesisRight),
                .reserved(.semicolon)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .type(.int),
                .identifier("fuga"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.semicolon),
                .reserved(.braceRight)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.squareLeft),
                .number("1"),
                .reserved(.squareRight),
                .reserved(.semicolon)
            ]
        )
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
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.squareLeft),
                .number("1"),
                .reserved(.add),
                .identifier("b"),
                .reserved(.squareRight),
                .reserved(.semicolon)
            ]
        )
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
