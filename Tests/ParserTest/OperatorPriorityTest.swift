import XCTest
@testable import Parser
import Tokenizer

final class OperatorPriorityTest: XCTestCase {

    func testAddPriority() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.add, sourceIndex: 3),
            .number("3", sourceIndex: 4),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let addNode = Node(kind: .add, left: leftNode, right: rightNode, token: .reserved(.add, sourceIndex: 1))

        let rightNode2 = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 4))
        let rootNode = Node(kind: .add, left: addNode, right: rightNode2, token: .reserved(.add, sourceIndex: 3))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testMulPriority() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.mul, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.mul, sourceIndex: 3),
            .number("3", sourceIndex: 4),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let addNode = Node(kind: .mul, left: leftNode, right: rightNode, token: .reserved(.mul, sourceIndex: 1))

        let rightNode2 = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 4))
        let rootNode = Node(kind: .mul, left: addNode, right: rightNode2, token: .reserved(.mul, sourceIndex: 3))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testAddAndMulPriority() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.mul, sourceIndex: 3),
            .number("3", sourceIndex: 4),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 4))
        let mulNode = Node(kind: .mul, left: leftNode, right: rightNode, token: .reserved(.mul, sourceIndex: 3))

        let leftNode2 = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rootNode = Node(kind: .add, left: leftNode2, right: mulNode, token: .reserved(.add, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testParenthesisPriority() throws {
        let node = try parse(tokens: [
            .reserved(.parenthesisLeft, sourceIndex: 0),
            .number("1", sourceIndex: 1),
            .reserved(.add, sourceIndex: 2),
            .number("2", sourceIndex: 3),
            .reserved(.parenthesisRight, sourceIndex: 4),
            .reserved(.mul, sourceIndex: 5),
            .number("3", sourceIndex: 6),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 1))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
        let addNode = Node(kind: .add, left: leftNode, right: rightNode, token: .reserved(.add, sourceIndex: 2))

        let rightNode2 = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 6))
        let rootNode = Node(kind: .mul, left: addNode, right: rightNode2, token: .reserved(.mul, sourceIndex: 5))

        XCTAssertEqual(
            node,
            rootNode
        )
    }
}
