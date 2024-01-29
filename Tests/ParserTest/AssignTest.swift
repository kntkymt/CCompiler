import XCTest
@testable import Parser
@testable import AST
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
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
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
            )
        )
    }

    func testAssignTo2Var() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .identifier("a"),
                .reserved(.assign),
                .identifier("b"),
                .reserved(.assign),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: InfixOperatorExprSyntax(
                        left: DeclReferenceSyntax(baseName: TokenSyntax(token: tokens[2])),
                        operator: TokenSyntax(token: tokens[3]),
                        right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[4]))
                    )
                ),
                semicolon: TokenSyntax(token: tokens[5])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: DeclReferenceNode(baseName: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .assign,
                right: InfixOperatorExprNode(
                    left: DeclReferenceNode(baseName: tokens[2].text, sourceRange: tokens[2].sourceRange),
                    operator: .assign,
                    right: IntegerLiteralNode(literal: tokens[4].text, sourceRange: tokens[4].sourceRange),
                    sourceRange: SourceRange(start: tokens[2].sourceRange.start, end: tokens[4].sourceRange.end)
                ),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[4].sourceRange.end)
            )
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let tokens: [Token] = buildTokens(
            kinds: [
                .integerLiteral("1"),
                .reserved(.assign),
                .integerLiteral("2"),
                .reserved(.semicolon)
            ]
        )
        let syntax = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(syntax.sourceTokens, tokens)

        XCTAssertEqual(
            syntax,
            BlockItemSyntax(
                item: InfixOperatorExprSyntax(
                    left: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[0])),
                    operator: TokenSyntax(token: tokens[1]),
                    right: IntegerLiteralSyntax(literal: TokenSyntax(token: tokens[2]))
                ),
                semicolon: TokenSyntax(token: tokens[3])
            )
        )

        let node = ASTGenerator.generate(syntax: syntax)

        XCTAssertEqual(
            node as! InfixOperatorExprNode,
            InfixOperatorExprNode(
                left: IntegerLiteralNode(literal: tokens[0].text, sourceRange: tokens[0].sourceRange),
                operator: .assign,
                right: IntegerLiteralNode(literal: tokens[2].text, sourceRange: tokens[2].sourceRange),
                sourceRange: SourceRange(start: tokens[0].sourceRange.start, end: tokens[2].sourceRange.end)
            )
        )
    }
}
