import XCTest
@testable import Parser
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let tokens: [Token] = [
            .identifier("a", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: AssignNode(token: tokens[1]),
                left: IdentifierNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]), 
                sourceTokens: Array(tokens[0...2])
            )
        )
    }

    func testAssignTo2Var() throws {
        let tokens: [Token] = [
            .identifier("a", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .identifier("b", sourceIndex: 2),
            .reserved(.assign, sourceIndex: 3),
            .number("2", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: AssignNode(token: tokens[1]),
                left: IdentifierNode(token: tokens[0]),
                right: InfixOperatorExpressionNode(
                    operator: AssignNode(token: tokens[3]),
                    left: IdentifierNode(token: tokens[2]),
                    right: IntegerLiteralNode(token: tokens[4]), 
                    sourceTokens: Array(tokens[2...4])
                ),
                sourceTokens: Array(tokens[0...4])
            )
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! InfixOperatorExpressionNode,
            InfixOperatorExpressionNode(
                operator: AssignNode(token: tokens[1]),
                left: IntegerLiteralNode(token: tokens[0]),
                right: IntegerLiteralNode(token: tokens[2]),
                sourceTokens: Array(tokens[0...2])
            )
        )
    }
}
