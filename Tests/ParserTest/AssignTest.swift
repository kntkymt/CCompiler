import XCTest
@testable import Parser
import Tokenizer

final class AssignTest: XCTestCase {

    func testAssignToVar() throws {
        let node = try parse(tokens: [
            .identifier("a", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ])[0]

        let leftNode = Node(kind: .localVariable, left: nil, right: nil, token: .identifier("a", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .assign, left: leftNode, right: rightNode, token: .reserved(.assign, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testAssignTo2Var() throws {
        let node = try parse(tokens: [
            .identifier("a", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .identifier("b", sourceIndex: 2),
            .reserved(.assign, sourceIndex: 3),
            .number("2", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5)
        ])[0]

        let childLeft = Node(kind: .localVariable, left: nil, right: nil, token: .identifier("b", sourceIndex: 2))
        let childRight = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 4))
        let childNode = Node(kind: .assign, left: childLeft, right: childRight, token: .reserved(.assign, sourceIndex: 3))

        let leftNode = Node(kind: .localVariable, left: nil, right: nil, token: .identifier("a", sourceIndex: 0))
        let rootNode = Node(kind: .assign, left: leftNode, right: childNode, token: .reserved(.assign, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    // 数への代入は文法上は許される、意味解析で排除する
    func testAssingToNumber() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.assign, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3)
        ])[0]

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .assign, left: leftNode, right: rightNode, token: .reserved(.assign, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }
}
