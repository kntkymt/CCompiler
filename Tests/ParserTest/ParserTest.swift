import XCTest
@testable import Parser
import Tokenizer

final class ParserTest: XCTestCase {

    func testNumber() throws {
        let node = try parse(tokens: [.number("5", sourceIndex: 0)])
        XCTAssertEqual(
            node,
            Node(kind: .number, left: nil, right: nil, token: .number("5", sourceIndex: 0))
        )
    }

    func testAdd() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.add, sourceIndex: 1),
            .number("2", sourceIndex: 2)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .add, left: leftNode, right: rightNode, token: .reserved(.add, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testAdd3() throws {
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

    func testMul() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.mul, sourceIndex: 1),
            .reserved(.parenthesisLeft, sourceIndex: 2),
            .number("2", sourceIndex: 3),
            .reserved(.add, sourceIndex: 4),
            .number("3", sourceIndex: 5),
            .reserved(.parenthesisRight, sourceIndex: 6),
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 5))
        let addNode = Node(kind: .add, left: leftNode, right: rightNode, token: .reserved(.add, sourceIndex: 4))

        let mulLeftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rootNode = Node(kind: .mul, left: mulLeftNode, right: addNode, token: .reserved(.mul, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testUnaryAdd() throws {
        let node = try parse(tokens: [
            .reserved(.add, sourceIndex: 0),
            .number("1", sourceIndex: 1)
        ])

        let numberNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 1))

        XCTAssertEqual(
            node,
            numberNode
        )
    }

    func testUnarySub() throws {
        let node = try parse(tokens: [
            .reserved(.sub, sourceIndex: 0),
            .number("1", sourceIndex: 1)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("0", sourceIndex: 1))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 1))
        let rootNode = Node(kind: .sub, left: leftNode, right: rightNode, token: .reserved(.sub, sourceIndex: 0))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testCompare() throws {
        try XCTContext.runActivity(named: "equal") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.equal, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
            let rootNode = Node(kind: .equal, left: leftNode, right: rightNode, token: .reserved(.equal, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "notEqual") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.notEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
            let rootNode = Node(kind: .notEqual, left: leftNode, right: rightNode, token: .reserved(.notEqual, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "greaterThan") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.greaterThan, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
            let rootNode = Node(kind: .lessThan, left: rightNode, right: leftNode, token: .reserved(.greaterThan, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.greaterThanOrEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
            let rootNode = Node(kind: .lessThanOrEqual, left: rightNode, right: leftNode, token: .reserved(.greaterThanOrEqual, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "lessThan") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.lessThan, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
            let rootNode = Node(kind: .lessThan, left: leftNode, right: rightNode, token: .reserved(.lessThan, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            let node = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.lessThanOrEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ])

            let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
            let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 3))
            let rootNode = Node(kind: .lessThanOrEqual, left: leftNode, right: rightNode, token: .reserved(.lessThanOrEqual, sourceIndex: 1))

            XCTAssertEqual(
                node,
                rootNode
            )
        }
    }
}
