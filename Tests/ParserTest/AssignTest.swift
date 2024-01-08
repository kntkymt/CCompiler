import XCTest
@testable import Parser
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("a"), sourceIndex: 0),
            Token(kind: .reserved(.assign), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }

    func testAssignTo2Var() throws {
        let tokens: [Token] = [
            Token(kind: .identifier("a"), sourceIndex: 0),
            Token(kind: .reserved(.assign), sourceIndex: 1),
            Token(kind: .identifier("b"), sourceIndex: 2),
            Token(kind: .reserved(.assign), sourceIndex: 3),
            Token(kind: .number("2"), sourceIndex: 4),
            Token(kind: .reserved(.semicolon), sourceIndex: 5)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IdentifierNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: InfixOperatorExpressionNode(
                        left: IdentifierNode(token: tokens[2]),
                        operator: AssignNode(token: tokens[3]),
                        right: IntegerLiteralNode(token: tokens[4])
                    )
                ),
                semicolonToken: tokens[5]
            )
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let tokens: [Token] = [
            Token(kind: .number("1"), sourceIndex: 0),
            Token(kind: .reserved(.assign), sourceIndex: 1),
            Token(kind: .number("2"), sourceIndex: 2),
            Token(kind: .reserved(.semicolon), sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(node.sourceTokens, tokens)

        XCTAssertEqual(
            node,
            BlockItemNode(
                item: InfixOperatorExpressionNode(
                    left: IntegerLiteralNode(token: tokens[0]),
                    operator: AssignNode(token: tokens[1]),
                    right: IntegerLiteralNode(token: tokens[2])
                ),
                semicolonToken: tokens[3]
            )
        )
    }
}
