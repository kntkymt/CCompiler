import XCTest
@testable import Parser
import Tokenizer

final class IfTest: XCTestCase {

    func testIf() throws {
        let node = try parse(tokens: [
            .keyword(.if, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 2),
            .number("1", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .number("2", sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6)
        ])[0]

        let condition = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 3))
        let trueStatement = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 5))
        let ifNode = Node(kind: .if, left: condition, right: trueStatement, token: .keyword(.if, sourceIndex: 0))

        XCTAssertEqual(node, ifNode)
    }

    func testIfElse() throws {
        let node = try parse(tokens: [
            .keyword(.if, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 2),
            .number("1", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .number("2", sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6),
            .keyword(.else, sourceIndex: 7),
            .number("3", sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ])[0]

        let condition = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 3))
        let trueStatement = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 5))
        let falseStatement = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 8))

        let elseNode = Node(kind: .else, left: trueStatement, right: falseStatement, token: .keyword(.else, sourceIndex: 7))
        let ifNode = Node(kind: .if, left: condition, right: elseNode, token: .keyword(.if, sourceIndex: 0))

        XCTAssertEqual(node, ifNode)
    }
}
