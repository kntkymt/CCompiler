import XCTest
@testable import Parser
import Tokenizer

final class OperatorsTest: XCTestCase {

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

    func testSub() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.sub, sourceIndex: 1),
            .number("2", sourceIndex: 2)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .sub, left: leftNode, right: rightNode, token: .reserved(.sub, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testMul() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.mul, sourceIndex: 1),
            .number("2", sourceIndex: 2)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .mul, left: leftNode, right: rightNode, token: .reserved(.mul, sourceIndex: 1))

        XCTAssertEqual(
            node,
            rootNode
        )
    }

    func testDiv() throws {
        let node = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.div, sourceIndex: 1),
            .number("2", sourceIndex: 2)
        ])

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0))
        let rightNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2))
        let rootNode = Node(kind: .div, left: leftNode, right: rightNode, token: .reserved(.div, sourceIndex: 1))

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

    func testEqual() throws {
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

    func testNotEqual() throws {
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

    func testGreaterThan() throws {
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

    func testGreaterThanOrEqual() throws {
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

    func testLessThan() throws {
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

    func testLessThanOrEqual() throws {
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
