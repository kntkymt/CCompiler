import XCTest
@testable import Parser
@testable import AST
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
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(
                statements: [
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            functionName: TokenSyntax(token: tokens[1]),
                            parenthesisLeft: TokenSyntax(token: tokens[2]),
                            parameters: [],
                            parenthesisRight: TokenSyntax(token: tokens[3]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[4]),
                                items: [
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[5])), semicolon: TokenSyntax(token: tokens[6])),
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[7])), semicolon: TokenSyntax(token: tokens[8])),
                                ],
                                braceRight: TokenSyntax(token: tokens[9])
                            )
                        )
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[10])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    FunctionDeclNode(
                        returnType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        functionName: tokens[1].text,
                        parameters: [],
                        block: BlockStatementNode(
                            items: [
                                IntegerLiteralNode(literal: tokens[5].text, sourceRange: tokens[5].sourceRange),
                                IntegerLiteralNode(literal: tokens[7].text, sourceRange: tokens[7].sourceRange)
                            ],
                            sourceRange: SourceRange(start: tokens[4].sourceRange.start, end: tokens[9].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[9].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[10].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(
                statements: [
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: PointerTypeSyntax(referenceType: TypeSyntax(type: TokenSyntax(token: tokens[0])), pointer: TokenSyntax(token: tokens[1])),
                            functionName: TokenSyntax(token: tokens[2]),
                            parenthesisLeft: TokenSyntax(token: tokens[3]),
                            parameters: [],
                            parenthesisRight: TokenSyntax(token: tokens[4]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[5]),
                                items: [
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[6])), semicolon: TokenSyntax(token: tokens[7])),
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[8])), semicolon: TokenSyntax(token: tokens[9])),
                                ],
                                braceRight: TokenSyntax(token: tokens[10])
                            )
                        )
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[11])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    FunctionDeclNode(
                        returnType: PointerTypeNode(
                            referenceType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                            sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
                        ),
                        functionName: tokens[2].text,
                        parameters: [],
                        block: BlockStatementNode(
                            items: [
                                IntegerLiteralNode(literal: tokens[6].text, sourceRange: tokens[6].sourceRange),
                                IntegerLiteralNode(literal: tokens[8].text, sourceRange: tokens[8].sourceRange)
                            ],
                            sourceRange: SourceRange(start: tokens[5].sourceRange.start, end: tokens[10].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[10].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[11].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: FunctionCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    arguments: [],
                    parenthesisRight: TokenSyntax(token: tokens[2])
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! FunctionCallExprNode,
            FunctionCallExprNode(
                identifier: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                arguments: [],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(
                statements: [
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            functionName: TokenSyntax(token: tokens[1]),
                            parenthesisLeft: TokenSyntax(token: tokens[2]),
                            parameters: [
                                FunctionParameterSyntax(type: TypeSyntax(type: TokenSyntax(token: tokens[3])), identifier: TokenSyntax(token: tokens[4]), comma: TokenSyntax(token: tokens[5])),
                                FunctionParameterSyntax(type: TypeSyntax(type: TokenSyntax(token: tokens[6])), identifier: TokenSyntax(token: tokens[7]))
                            ],
                            parenthesisRight: TokenSyntax(token: tokens[8]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[9]),
                                items: [
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[10])), semicolon: TokenSyntax(token: tokens[11])),
                                ],
                                braceRight: TokenSyntax(token: tokens[12])
                            )
                        )
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[13])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    FunctionDeclNode(
                        returnType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        functionName: tokens[1].text,
                        parameters: [
                            FunctionParameterNode(
                                type: TypeNode(type: .int, sourceRange: tokens[3].sourceRange),
                                identifierName: tokens[4].text,
                                sourceRange: SourceRange(start: tokens[3].sourceRange.start, end: tokens[5].sourceRange.end)
                            ),
                            FunctionParameterNode(
                                type: TypeNode(type: .int, sourceRange: tokens[6].sourceRange),
                                identifierName: tokens[7].text,
                                sourceRange: SourceRange(start: tokens[6].sourceRange.start, end: tokens[7].sourceRange.end)
                            )
                        ],
                        block: BlockStatementNode(
                            items: [
                                IntegerLiteralNode(literal: tokens[10].text, sourceRange: tokens[10].sourceRange)
                            ],
                            sourceRange: SourceRange(start: tokens[9].sourceRange.start, end: tokens[12].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[12].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[13].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: FunctionCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    arguments: [
                        ExprListItemSyntax(
                            expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                            comma: TokenSyntax(token: tokens[3])
                        ),
                        ExprListItemSyntax(expression: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[4])))
                    ],
                    parenthesisRight: TokenSyntax(token: tokens[5])
                ),
                semicolon: TokenSyntax(token: tokens[6])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! FunctionCallExprNode,
            FunctionCallExprNode(
                identifier: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                arguments: [
                    IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    DeclReferenceNode(baseName: tokens[4].text, sourceRange: tokens[4].sourceRange)
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[5].sourceRange.end)
            )
        )
    }

    func testFunctionCallWithArrayParameter() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("main"),
                .reserved(.parenthesisLeft),
                .type(.int),
                .identifier("a"),
                .reserved(.squareLeft),
                .reserved(.squareRight),
                .reserved(.parenthesisRight),
                .reserved(.braceLeft),
                .reserved(.braceRight),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(
                statements: [
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            functionName: TokenSyntax(token: tokens[1]),
                            parenthesisLeft: TokenSyntax(token: tokens[2]),
                            parameters: [
                                FunctionParameterSyntax(
                                    type: TypeSyntax(type: TokenSyntax(token: tokens[3])),
                                    identifier: TokenSyntax(token: tokens[4]),
                                    squareLeft: TokenSyntax(token: tokens[5]),
                                    squareRight: TokenSyntax(token: tokens[6])
                                )
                            ],
                            parenthesisRight: TokenSyntax(token: tokens[7]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[8]),
                                items: [],
                                braceRight: TokenSyntax(token: tokens[9])
                            )
                        )
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[10])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    FunctionDeclNode(
                        returnType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        functionName: tokens[1].text,
                        parameters: [
                            FunctionParameterNode(
                                type: PointerTypeNode(
                                    referenceType: TypeNode(type: .int, sourceRange: tokens[3].sourceRange),
                                    sourceRange: tokens[3].sourceRange
                                ),
                                identifierName: tokens[4].text,
                                sourceRange: SourceRange(start: tokens[3].sourceRange.start, end: tokens[6].sourceRange.end)
                            )
                        ],
                        block: BlockStatementNode(
                            items: [],
                            sourceRange: SourceRange(start: tokens[8].sourceRange.start, end: tokens[9].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[9].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[10].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).parse()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            SourceFileSyntax(
                statements: [
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            functionName: TokenSyntax(token: tokens[1]),
                            parenthesisLeft: TokenSyntax(token: tokens[2]),
                            parameters: [],
                            parenthesisRight: TokenSyntax(token: tokens[3]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[4]),
                                items: [
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[5])), semicolon: TokenSyntax(token: tokens[6]))
                                ],
                                braceRight: TokenSyntax(token: tokens[7])
                            )
                        )
                    ),
                    BlockItemSyntax(
                        item: FunctionDeclSyntax(
                            returnType: TypeSyntax(type: TokenSyntax(token: tokens[8])),
                            functionName: TokenSyntax(token: tokens[9]),
                            parenthesisLeft: TokenSyntax(token: tokens[10]),
                            parameters: [],
                            parenthesisRight: TokenSyntax(token: tokens[11]),
                            block: BlockStatementSyntax(
                                braceLeft: TokenSyntax(token: tokens[12]),
                                items: [
                                    BlockItemSyntax(item: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[13])), semicolon: TokenSyntax(token: tokens[14]))
                                ],
                                braceRight: TokenSyntax(token: tokens[15])
                            )
                        )
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[16])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    FunctionDeclNode(
                        returnType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        functionName: tokens[1].text,
                        parameters: [],
                        block: BlockStatementNode(
                            items: [
                                IntegerLiteralNode(literal: tokens[5].text, sourceRange: tokens[5].sourceRange)
                            ],
                            sourceRange: SourceRange(start: tokens[4].sourceRange.start, end: tokens[7].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[7].sourceRange.end)
                    ),
                    FunctionDeclNode(
                        returnType: TypeNode(type: .int, sourceRange: tokens[8].sourceRange),
                        functionName: tokens[9].text,
                        parameters: [],
                        block: BlockStatementNode(
                            items: [
                                IntegerLiteralNode(literal: tokens[13].text, sourceRange: tokens[13].sourceRange)
                            ],
                            sourceRange: SourceRange(start: tokens[12].sourceRange.start, end: tokens[15].sourceRange.end)
                        ),
                        sourceRange: SourceRange(start: tokens[8].sourceRange.start, end: tokens[15].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[16].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: SubscriptCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    squareLeft: TokenSyntax(token: tokens[1]),
                    argument: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    squareRight: TokenSyntax(token: tokens[3])
                ),
                semicolon: TokenSyntax(token: tokens[4])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SubscriptCallExprNode,
            SubscriptCallExprNode(
                identifier: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                argument: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[3].sourceRange.end)
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
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: SubscriptCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    squareLeft: TokenSyntax(token: tokens[1]),
                    argument: InfixOperatorExprSyntax(
                        left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                        operator: TokenSyntax(token: tokens[3]),
                        right: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[4]))
                    ),
                    squareRight: TokenSyntax(token: tokens[5])
                ),
                semicolon: TokenSyntax(token: tokens[6])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SubscriptCallExprNode,
            SubscriptCallExprNode(
                identifier: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                argument: InfixOperatorExprNode(
                    left: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    operator: .add,
                    right: DeclReferenceNode(baseName: tokens[4].text, sourceRange: tokens[4].sourceRange),
                    sourceRange: SourceRange(start: tokens[2].sourceRange.start, end: tokens[4].sourceRange.end)
                ),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[5].sourceRange.end)
            )
        )
    }
}
