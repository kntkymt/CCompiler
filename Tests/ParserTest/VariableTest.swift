import XCTest
@testable import Parser
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
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: TypeNode(type: TokenNode(token: tokens[0])),
                    identifier: TokenNode(token: tokens[1])
                ),
                semicolon: TokenNode(token: tokens[2])
            )
        )
    }

    func testDeclAndInitVariable() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.assign),
                .number("1"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: TypeNode(type: TokenNode(token: tokens[0])),
                    identifier: TokenNode(token: tokens[1]),
                    equal: TokenNode(token: tokens[2]),
                    initializerExpr: IntegerLiteralNode(literal: TokenNode(token: tokens[3]))
                ),
                semicolon: TokenNode(token: tokens[4])
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
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: PointerTypeNode(
                        referenceType: TypeNode(type: TokenNode(token: tokens[0])),
                        pointer: TokenNode(token: tokens[1])
                    ),
                    identifier: TokenNode(token: tokens[2])
                ),
                semicolon: TokenNode(token: tokens[3])
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
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: PointerTypeNode(
                        referenceType: PointerTypeNode(
                            referenceType: TypeNode(type: TokenNode(token: tokens[0])),
                            pointer: TokenNode(token: tokens[1])
                        ),
                        pointer: TokenNode(token: tokens[2])
                    ),
                    identifier: TokenNode(token: tokens[3])
                ),
                semicolon: TokenNode(token: tokens[4])
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
                .number("4"),
                .reserved(.squareRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(type: TokenNode(token: tokens[0])),
                        squareLeft: TokenNode(token: tokens[2]),
                        arraySize: TokenNode(token: tokens[3]),
                        squareRight: TokenNode(token: tokens[4])
                    ),
                    identifier: TokenNode(token: tokens[1])
                ),
                semicolon: TokenNode(token: tokens[5])
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
                .number("2"),
                .reserved(.squareRight),
                .reserved(.assign),
                .reserved(.braceLeft),
                .number("1"),
                .reserved(.comma),
                .number("2"),
                .reserved(.braceRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(type: TokenNode(token: tokens[0])),
                        squareLeft: TokenNode(token: tokens[2]),
                        arraySize: TokenNode(token: tokens[3]),
                        squareRight: TokenNode(token: tokens[4])
                    ),
                    identifier: TokenNode(token: tokens[1]),
                    equal: TokenNode(token: tokens[5]),
                    initializerExpr: ArrayExpressionNode(
                        braceLeft: TokenNode(token: tokens[6]),
                        exprListNodes: [
                            ExpressionListItemNode(expression: IntegerLiteralNode(literal: TokenNode(token: tokens[7])), comma: TokenNode(token: tokens[8])),
                            ExpressionListItemNode(expression: IntegerLiteralNode(literal: TokenNode(token: tokens[9])))
                        ],
                        braceRight: TokenNode(token: tokens[10])
                    )
                ),
                semicolon: TokenNode(token: tokens[11])
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
                .number("2"),
                .reserved(.squareRight),
                .reserved(.assign),
                .stringLiteral("ai"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(type: TokenNode(token: tokens[0])),
                        squareLeft: TokenNode(token: tokens[2]),
                        arraySize: TokenNode(token: tokens[3]),
                        squareRight: TokenNode(token: tokens[4])
                    ),
                    identifier: TokenNode(token: tokens[1]),
                    equal: TokenNode(token: tokens[5]),
                    initializerExpr: StringLiteralNode(literal: TokenNode(token: tokens[6]))
                ),
                semicolon: TokenNode(token: tokens[7])
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
                .number("4"),
                .reserved(.squareRight),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: PointerTypeNode(referenceType: TypeNode(type: TokenNode(token: tokens[0])), pointer: TokenNode(token: tokens[1])),
                        squareLeft: TokenNode(token: tokens[3]),
                        arraySize: TokenNode(token: tokens[4]),
                        squareRight: TokenNode(token: tokens[5])
                    ),
                    identifier: TokenNode(token: tokens[2])
                ),
                semicolon: TokenNode(token: tokens[6])
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
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: VariableDeclNode(
                            type: TypeNode(type: TokenNode(token: tokens[0])),
                            identifier: TokenNode(token: tokens[1])
                        ),
                        semicolon: TokenNode(token: tokens[2])
                    )
                ], 
                endOfFile: TokenNode(token: tokens[3])
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
        let node = try Parser(tokens: tokens).parse()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            SourceFileNode(
                statements: [
                    BlockItemNode(
                        item: VariableDeclNode(
                            type: PointerTypeNode(
                                referenceType: TypeNode(type: TokenNode(token: tokens[0])),
                                pointer: TokenNode(token: tokens[1])
                            ),
                            identifier: TokenNode(token: tokens[2])
                        ),
                        semicolon: TokenNode(token: tokens[3])
                    )
                ],
                endOfFile: TokenNode(token: tokens[4])
            )
        )
    }
}
