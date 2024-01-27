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
                .integerLiteral("1"),
                .reserved(.semicolon),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .endOfFile
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
                            returnType: TypeNode(type: TokenNode(token: tokens[0])),
                            functionName: TokenNode(token: tokens[1]),
                            parenthesisLeft: TokenNode(token: tokens[2]),
                            parameters: [],
                            parenthesisRight: TokenNode(token: tokens[3]),
                            block: BlockStatementNode(
                                braceLeft: TokenNode(token: tokens[4]),
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[5])), semicolon: TokenNode(token: tokens[6])),
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[7])), semicolon: TokenNode(token: tokens[8])),
                                ],
                                braceRight: TokenNode(token: tokens[9])
                            )
                        )
                    )
                ],
                endOfFile: TokenNode(token: tokens[10])
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
                .integerLiteral("1"),
                .reserved(.semicolon),
                .integerLiteral("2"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .endOfFile
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
                            returnType: PointerTypeNode(referenceType: TypeNode(type: TokenNode(token: tokens[0])), pointer: TokenNode(token: tokens[1])),
                            functionName: TokenNode(token: tokens[2]),
                            parenthesisLeft: TokenNode(token: tokens[3]),
                            parameters: [],
                            parenthesisRight: TokenNode(token: tokens[4]),
                            block: BlockStatementNode(
                                braceLeft: TokenNode(token: tokens[5]),
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[6])), semicolon: TokenNode(token: tokens[7])),
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[8])), semicolon: TokenNode(token: tokens[9])),
                                ],
                                braceRight: TokenNode(token: tokens[10])
                            )
                        )
                    )
                ],
                endOfFile: TokenNode(token: tokens[11])
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
                    identifier: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    arguments: [],
                    parenthesisRight: TokenNode(token: tokens[2])
                ),
                semicolon: TokenNode(token: tokens[3])
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
                .integerLiteral("1"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .endOfFile
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
                            returnType: TypeNode(type: TokenNode(token: tokens[0])),
                            functionName: TokenNode(token: tokens[1]),
                            parenthesisLeft: TokenNode(token: tokens[2]),
                            parameters: [
                                FunctionParameterNode(type: TypeNode(type: TokenNode(token: tokens[3])), identifier: TokenNode(token: tokens[4]), comma: TokenNode(token: tokens[5])),
                                FunctionParameterNode(type: TypeNode(type: TokenNode(token: tokens[6])), identifier: TokenNode(token: tokens[7]))
                            ],
                            parenthesisRight: TokenNode(token: tokens[8]),
                            block: BlockStatementNode(
                                braceLeft: TokenNode(token: tokens[9]),
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[10])), semicolon: TokenNode(token: tokens[11])),
                                ],
                                braceRight: TokenNode(token: tokens[12])
                            )
                        )
                    )
                ],
                endOfFile: TokenNode(token: tokens[13])
            )
        )
    }

    func testFunctionCallWithArguments() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .integerLiteral("1"),
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
                    identifier: TokenNode(token: tokens[0]),
                    parenthesisLeft: TokenNode(token: tokens[1]),
                    arguments: [
                        ExpressionListItemNode(
                            expression: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                            comma: TokenNode(token: tokens[3])
                        ),
                        ExpressionListItemNode(expression: IdentifierNode(baseName: TokenNode(token: tokens[4])))
                    ],
                    parenthesisRight: TokenNode(token: tokens[5])
                ),
                semicolon: TokenNode(token: tokens[6])
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
                .integerLiteral("1"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .type(.int),
                .identifier("fuga"),
                .reserved(.parenthesisLeft),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .integerLiteral("1"),
                .reserved(.semicolon),
                .reserved(.braceRight),
                .endOfFile
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
                            returnType: TypeNode(type: TokenNode(token: tokens[0])),
                            functionName: TokenNode(token: tokens[1]),
                            parenthesisLeft: TokenNode(token: tokens[2]),
                            parameters: [],
                            parenthesisRight: TokenNode(token: tokens[3]),
                            block: BlockStatementNode(
                                braceLeft: TokenNode(token: tokens[4]),
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[5])), semicolon: TokenNode(token: tokens[6]))
                                ],
                                braceRight: TokenNode(token: tokens[7])
                            )
                        )
                    ),
                    BlockItemNode(
                        item: FunctionDeclNode(
                            returnType: TypeNode(type: TokenNode(token: tokens[8])),
                            functionName: TokenNode(token: tokens[9]),
                            parenthesisLeft: TokenNode(token: tokens[10]),
                            parameters: [],
                            parenthesisRight: TokenNode(token: tokens[11]),
                            block: BlockStatementNode(
                                braceLeft: TokenNode(token: tokens[12]),
                                items: [
                                    BlockItemNode(item: IntegerLiteralNode(literal: TokenNode(token: tokens[13])), semicolon: TokenNode(token: tokens[14]))
                                ],
                                braceRight: TokenNode(token: tokens[15])
                            )
                        )
                    )
                ],
                endOfFile: TokenNode(token: tokens[16])
            )
        )
    }

    func testSubscriptCall() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("1"),
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
                    identifier: IdentifierNode(baseName: TokenNode(token: tokens[0])),
                    squareLeft: TokenNode(token: tokens[1]),
                    argument: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                    squareRight: TokenNode(token: tokens[3])
                ),
                semicolon: TokenNode(token: tokens[4])
            )
        )
    }

    func testSubscriptCall2() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("1"),
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
                    identifier: IdentifierNode(baseName: TokenNode(token: tokens[0])),
                    squareLeft: TokenNode(token: tokens[1]),
                    argument: InfixOperatorExpressionNode(
                        left: IntegerLiteralNode(literal: TokenNode(token: tokens[2])),
                        operator: BinaryOperatorNode(operator: TokenNode(token: tokens[3])),
                        right: IdentifierNode(baseName: TokenNode(token: tokens[4]))
                    ),
                    squareRight: TokenNode(token: tokens[5])
                ),
                semicolon: TokenNode(token: tokens[6])
            )
        )
    }
}
