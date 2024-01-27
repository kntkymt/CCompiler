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
                    identifier: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    arguments: [],
                    parenthesisRight: TokenSyntax(token: tokens[2])
                ),
                semicolon: TokenSyntax(token: tokens[3])
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
                    identifier: TokenSyntax(token: tokens[0]),
                    parenthesisLeft: TokenSyntax(token: tokens[1]),
                    arguments: [
                        ExprListItemSyntax(
                            expression: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                            comma: TokenSyntax(token: tokens[3])
                        ),
                        ExprListItemSyntax(expression: IdentifierSyntax(baseName: TokenSyntax(token: tokens[4])))
                    ],
                    parenthesisRight: TokenSyntax(token: tokens[5])
                ),
                semicolon: TokenSyntax(token: tokens[6])
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
                    identifier: IdentifierSyntax(baseName: TokenSyntax(token: tokens[0])),
                    squareLeft: TokenSyntax(token: tokens[1]),
                    argument: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                    squareRight: TokenSyntax(token: tokens[3])
                ),
                semicolon: TokenSyntax(token: tokens[4])
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
                    identifier: IdentifierSyntax(baseName: TokenSyntax(token: tokens[0])),
                    squareLeft: TokenSyntax(token: tokens[1]),
                    argument: InfixOperatorExprSyntax(
                        left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2])),
                        operator: BinaryOperatorSyntax(operator: TokenSyntax(token: tokens[3])),
                        right: IdentifierSyntax(baseName: TokenSyntax(token: tokens[4]))
                    ),
                    squareRight: TokenSyntax(token: tokens[5])
                ),
                semicolon: TokenSyntax(token: tokens[6])
            )
        )
    }
}
