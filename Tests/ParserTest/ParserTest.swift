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

    func testUnaryAdd() throws {
        let node = try parse(tokens: [
            Token(kind: .add, value: "+", sourceIndex: 0),
            Token(kind: .number, value: "1", sourceIndex: 1),
        ])

        let numberNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 1))

        XCTAssertEqual(
            node,
            numberNode
        )
    }

    func testUnarySub() throws {
        let node = try parse(tokens: [
            Token(kind: .sub, value: "-", sourceIndex: 0),
            Token(kind: .number, value: "1", sourceIndex: 1),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "0", sourceIndex: 1))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 1))
        let rootNode = Node(kind: .sub, left: leftNode, right: rightNode, token: Token(kind: .sub, value: "-", sourceIndex: 0))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testCompare() throws {
        try XCTContext.runActivity(named: "equal") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .equal, value: "==", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 3),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 3))
            let rootNode = Node(kind: .equal, left: leftNode, right: rightNode, token: Token(kind: .equal, value: "==", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "notEqual") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .notEqual, value: "!=", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 3),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 3))
            let rootNode = Node(kind: .notEqual, left: leftNode, right: rightNode, token: Token(kind: .notEqual, value: "!=", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "greaterThan") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .greaterThan, value: ">", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 2),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 2))
            let rootNode = Node(kind: .lessThan, left: rightNode, right: leftNode, token: Token(kind: .greaterThan, value: ">", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .greaterThanOrEqual, value: ">=", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 3),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 3))
            let rootNode = Node(kind: .lessThanOrEqual, left: rightNode, right: leftNode, token: Token(kind: .greaterThanOrEqual, value: ">=", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "lessThan") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .lessThan, value: "<", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 2),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 2))
            let rootNode = Node(kind: .lessThan, left: leftNode, right: rightNode, token: Token(kind: .lessThan, value: "<", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            let node = try parse(tokens: [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .lessThanOrEqual, value: "<=", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 3),
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "2", sourceIndex: 3))
            let rootNode = Node(kind: .lessThanOrEqual, left: leftNode, right: rightNode, token: Token(kind: .lessThanOrEqual, value: "<=", sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }
    }
}
