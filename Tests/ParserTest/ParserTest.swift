import XCTest
@testable import Parser
import Tokenizer

final class ParserTest: XCTestCase {

    func testNumber() throws {
        let node = try parse(tokens: [Token(kind: .number, value: "5", sourceIndex: 0)])
        XCTAssertEqual(
            node,
            Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "5", sourceIndex: 0))
        )
    }

    func testAdd() throws {
        let node = try parse(tokens: [
            Token(kind: .number, value: "1", sourceIndex: 0),
            Token(kind: .add, value: "+", sourceIndex: 1),
            Token(kind: .number, value: "2", sourceIndex: 2)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 2))
        let rootNode = Node(kind: .add, left: leftNode, right: rightNode, token: Token(kind: .add, value: "+", sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testAdd3() throws {
        let node = try parse(tokens: [
            Token(kind: .number, value: "1", sourceIndex: 0),
            Token(kind: .add, value: "+", sourceIndex: 1),
            Token(kind: .number, value: "2", sourceIndex: 2),
            Token(kind: .add, value: "+", sourceIndex: 3),
            Token(kind: .number, value: "3", sourceIndex: 4)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 2))
        let addNode = Node(kind: .add, left: leftNode, right: rightNode, token: Token(kind: .add, value: "+", sourceIndex: 1))

        let rightNode2 = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "3", sourceIndex: 4))
        let rootNode = Node(kind: .add, left: addNode, right: rightNode2, token: Token(kind: .add, value: "+", sourceIndex: 3))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testMul() throws {
        let node = try parse(tokens: [
            Token(kind: .number, value: "1", sourceIndex: 0),
            Token(kind: .mul, value: "*", sourceIndex: 1),
            Token(kind: .parenthesisLeft, value: "(", sourceIndex: 2),
            Token(kind: .number, value: "2", sourceIndex: 3),
            Token(kind: .add, value: "+", sourceIndex: 4),
            Token(kind: .number, value: "3", sourceIndex: 5),
            Token(kind: .parenthesisRight, value: ")", sourceIndex: 6),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 3))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "3", sourceIndex: 5))
        let addNode = Node(kind: .add, left: leftNode, right: rightNode, token: Token(kind: .add, value: "+", sourceIndex: 4))

        let mulLeftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
        let rootNode = Node(kind: .mul, left: mulLeftNode, right: addNode, token: Token(kind: .mul, value: "*", sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }
}
