import XCTest
@testable import Parser
@testable import AST
import Tokenizer

final class VariableTest: XCTestCase {

    func testDeclVariable() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                    identifier: TokenSyntax(token: tokens[1])
                ),
                semicolon: TokenSyntax(token: tokens[2])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                identifierName: tokens[1].text,
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
            )
        )
    }

    func testDeclAndInitVariable() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.assign),
                .integerLiteral("1"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                    identifier: TokenSyntax(token: tokens[1]),
                    equal: TokenSyntax(token: tokens[2]),
                    initializerExpr: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[3]))
                ),
                semicolon: TokenSyntax(token: tokens[4])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                identifierName: tokens[1].text,
                initializerExpr: IntegerLiteralNode(literal: tokens[3].text, sourceRange: tokens[3].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[3].sourceRange.end)
            )
        )
    }

    func testDeclVariablePointer() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: PointerTypeSyntax(
                        referenceType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                        pointer: TokenSyntax(token: tokens[1])
                    ),
                    identifier: TokenSyntax(token: tokens[2])
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: PointerTypeNode(
                    referenceType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                    sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
                ),
                identifierName: tokens[2].text,
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
            )
        )
    }

    func testDeclVariablePointer2() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: PointerTypeSyntax(
                        referenceType: PointerTypeSyntax(
                            referenceType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            pointer: TokenSyntax(token: tokens[1])
                        ),
                        pointer: TokenSyntax(token: tokens[2])
                    ),
                    identifier: TokenSyntax(token: tokens[3])
                ),
                semicolon: TokenSyntax(token: tokens[4])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: PointerTypeNode(
                    referenceType: PointerTypeNode(
                        referenceType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
                    ),
                    sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
                ),
                identifierName: tokens[3].text,
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[3].sourceRange.end)
            )
        )
    }

    // FIXME: ArrayTypeのsourceTokenの順序がおかしくなる
    func testDeclVariableArray() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("4"),
                .reserved(.squareRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: ArrayTypeSyntax(
                        elementType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                        squareLeft: TokenSyntax(token: tokens[2]),
                        arraySize: TokenSyntax(token: tokens[3]),
                        squareRight: TokenSyntax(token: tokens[4])
                    ),
                    identifier: TokenSyntax(token: tokens[1])
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )
    }

    // FIXME: ArrayTypeのsourceTokenの順序がおかしくなる
    func testDeclAndInitVariableArray() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("2"),
                .reserved(.squareRight),
                .reserved(.assign),
                .reserved(.braceLeft),
                .integerLiteral("1"),
                .reserved(.comma),
                .integerLiteral("2"),
                .reserved(.braceRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: ArrayTypeSyntax(
                        elementType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                        squareLeft: TokenSyntax(token: tokens[2]),
                        arraySize: TokenSyntax(token: tokens[3]),
                        squareRight: TokenSyntax(token: tokens[4])
                    ),
                    identifier: TokenSyntax(token: tokens[1]),
                    equal: TokenSyntax(token: tokens[5]),
                    initializerExpr: InitListExprSyntax(
                        braceLeft: TokenSyntax(token: tokens[6]),
                        exprListSyntaxs: [
                            ExprListItemSyntax(expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[7])), comma: TokenSyntax(token: tokens[8])),
                            ExprListItemSyntax(expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[9])))
                        ],
                        braceRight: TokenSyntax(token: tokens[10])
                    )
                ),
                semicolon: TokenSyntax(token: tokens[11])
            )
        )
    }

    // FIXME: ArrayTypeのsourceTokenの順序がおかしくなる
    func testDeclAndInitVariableStringLiteral() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.char),
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("2"),
                .reserved(.squareRight),
                .reserved(.assign),
                .stringLiteral("ai"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: ArrayTypeSyntax(
                        elementType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                        squareLeft: TokenSyntax(token: tokens[2]),
                        arraySize: TokenSyntax(token: tokens[3]),
                        squareRight: TokenSyntax(token: tokens[4])
                    ),
                    identifier: TokenSyntax(token: tokens[1]),
                    equal: TokenSyntax(token: tokens[5]),
                    initializerExpr: StringLiteralSyntax(literal: TokenSyntax(token: tokens[6]))
                ),
                semicolon: TokenSyntax(token: tokens[7])
            )
        )
    }

    // FIXME: ArrayTypeのsourceTokenの順序がおかしくなる
    func testDeclVariableArrayPointer() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.squareLeft),
                .integerLiteral("4"),
                .reserved(.squareRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: VariableDeclSyntax(
                    type: ArrayTypeSyntax(
                        elementType: PointerTypeSyntax(referenceType: TypeSyntax(type: TokenSyntax(token: tokens[0])), pointer: TokenSyntax(token: tokens[1])),
                        squareLeft: TokenSyntax(token: tokens[3]),
                        arraySize: TokenSyntax(token: tokens[4]),
                        squareRight: TokenSyntax(token: tokens[5])
                    ),
                    identifier: TokenSyntax(token: tokens[2])
                ),
                semicolon: TokenSyntax(token: tokens[6])
            )
        )
    }

    func testGlobalVariableDecl() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.semicolon),
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
                        item: VariableDeclSyntax(
                            type: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                            identifier: TokenSyntax(token: tokens[1])
                        ),
                        semicolon: TokenSyntax(token: tokens[2])
                    )
                ], 
                endOfFile: TokenSyntax(token: tokens[3])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    VariableDeclNode(
                        type: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                        identifierName: tokens[1].text,
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[3].sourceRange.end)
            )
        )
    }

    func testGlobalVariableDeclPointer() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon),
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
                        item: VariableDeclSyntax(
                            type: PointerTypeSyntax(
                                referenceType: TypeSyntax(type: TokenSyntax(token: tokens[0])),
                                pointer: TokenSyntax(token: tokens[1])
                            ),
                            identifier: TokenSyntax(token: tokens[2])
                        ),
                        semicolon: TokenSyntax(token: tokens[3])
                    )
                ],
                endOfFile: TokenSyntax(token: tokens[4])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! SourceFileNode,
            SourceFileNode(
                statements: [
                    VariableDeclNode(
                        type: PointerTypeNode(
                            referenceType: TypeNode(type: .int, sourceRange: tokens[0].sourceRange),
                            sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[1].sourceRange.end)
                        ),
                        identifierName: tokens[2].text,
                        sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
                    )
                ],
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
            )
        )
    }
}
