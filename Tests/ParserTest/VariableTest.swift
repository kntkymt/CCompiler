import XCTest
@testable import Parser
import Tokenizer

final class VariableTest: XCTestCase {

    func testDeclVariable() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: TypeNode(typeToken: tokens[0]),
                    identifierToken: tokens[1]
                ),
                semicolonToken: tokens[2]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: TypeNode(typeToken: tokens[0]),
                    identifierToken: tokens[1],
                    initializerToken: tokens[2],
                    initializerExpr: IntegerLiteralNode(token: tokens[3])
                ),
                semicolonToken: tokens[4]
            )
        )
    }

    func testDeclVariablePointer() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: PointerTypeNode(
                        referenceType: TypeNode(typeToken: tokens[0]),
                        pointerToken: tokens[1]
                    ),
                    identifierToken: tokens[2]
                ),
                semicolonToken: tokens[3]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: PointerTypeNode(
                        referenceType: PointerTypeNode(
                            referenceType: TypeNode(typeToken: tokens[0]),
                            pointerToken: tokens[1]
                        ),
                        pointerToken: tokens[2]
                    ),
                    identifierToken: tokens[3]
                ),
                semicolonToken: tokens[4]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(typeToken: tokens[0]),
                        squareLeftToken: tokens[2],
                        arraySizeToken: tokens[3],
                        squareRightToken: tokens[4]
                    ),
                    identifierToken: tokens[1]
                ),
                semicolonToken: tokens[5]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(typeToken: tokens[0]),
                        squareLeftToken: tokens[2],
                        arraySizeToken: tokens[3],
                        squareRightToken: tokens[4]
                    ),
                    identifierToken: tokens[1],
                    initializerToken: tokens[5],
                    initializerExpr: ArrayExpressionNode(
                        braceLeft: tokens[6],
                        exprListNodes: [
                            ExpressionListItemNode(expression: IntegerLiteralNode(token: tokens[7]), comma: tokens[8]),
                            ExpressionListItemNode(expression: IntegerLiteralNode(token: tokens[9]))
                        ],
                        braceRight: tokens[10]
                    )
                ),
                semicolonToken: tokens[11]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: TypeNode(typeToken: tokens[0]),
                        squareLeftToken: tokens[2],
                        arraySizeToken: tokens[3],
                        squareRightToken: tokens[4]
                    ),
                    identifierToken: tokens[1],
                    initializerToken: tokens[5],
                    initializerExpr: StringLiteralNode(token: tokens[6])
                ),
                semicolonToken: tokens[7]
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
                .reserved(.semicolon)
            ]
        )
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: VariableDeclNode(
                    type: ArrayTypeNode(
                        elementType: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]),
                        squareLeftToken: tokens[3],
                        arraySizeToken: tokens[4],
                        squareRightToken: tokens[5]
                    ),
                    identifierToken: tokens[2]
                ),
                semicolonToken: tokens[6]
            )
        )
    }

    func testGlobalVariableDecl() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .identifier("a"),
                .reserved(.semicolon)
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
                            type: TypeNode(typeToken: tokens[0]),
                            identifierToken: tokens[1]
                        ),
                        semicolonToken: tokens[2]
                    )
                ]
            )
        )
    }

    func testGlobalVariableDeclPointer() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .type(.int),
                .reserved(.mul),
                .identifier("a"),
                .reserved(.semicolon)
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
                                referenceType: TypeNode(typeToken: tokens[0]),
                                pointerToken: tokens[1]
                            ),
                            identifierToken: tokens[2]
                        ),
                        semicolonToken: tokens[3]
                    )
                ]
            )
        )
    }
}
