import XCTest
@testable import Parser
@testable import AST
import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral1() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .stringLiteral("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: StringLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                semicolon: TokenSyntax(token: tokens[1])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        // ASTのliteralは""を除いたもの
        XCTAssertEqual(
            node as! StringLiteralNode,
            StringLiteralNode(literal: "a", sourceRange: tokens[0].sourceRange)
        )
    }

    func testStringLiteral2() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .stringLiteral("a"),
                .reserved(.semicolon),
                .endOfFile
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens.dropLast())

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: StringLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .assign,
                right: StringLiteralNode(literal: "a", sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
            )
        )
    }
}
