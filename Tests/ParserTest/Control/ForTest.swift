import XCTest
@testable import Parser
import Tokenizer

final class ForTest: XCTestCase {

    func testFor() throws {
        let node = try parse(tokens: [
            .keyword(.for, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 3),
            .number("1", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
            .number("2", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
            .number("3", sourceIndex: 8),
            .reserved(.parenthesisRight, sourceIndex: 9),
            .number("4", sourceIndex: 10),
            .reserved(.semicolon, sourceIndex: 11)
        ])[0]

        let postExpr = Node(kind: .number, left: nil, right: nil, token: .number("3", sourceIndex: 8))
        let statement = Node(kind: .number, left: nil, right: nil, token: .number("4", sourceIndex: 10))
        let forBody = Node(kind: .forBody, left: statement, right: postExpr, token: .keyword(.for, sourceIndex: 0))

        let condition = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 6))
        let forCondition = Node(kind: .forCondition, left: condition, right: forBody, token: .keyword(.for, sourceIndex: 0))

        let preExpr = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 4))
        let forRoot = Node(kind: .for, left: preExpr, right: forCondition, token: .keyword(.for, sourceIndex: 0))

        XCTAssertEqual(node, forRoot)
    }

    func testForNoNodes() throws {
        let node = try parse(tokens: [
            .keyword(.for, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 3),
            .reserved(.semicolon, sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5),
            .reserved(.parenthesisRight, sourceIndex: 6),
            .number("4", sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8)
        ])[0]

        let statement = Node(kind: .number, left: nil, right: nil, token: .number("4", sourceIndex: 7))
        let forBody = Node(kind: .forBody, left: statement, right: nil, token: .keyword(.for, sourceIndex: 0))

        let forCondition = Node(kind: .forCondition, left: nil, right: forBody, token: .keyword(.for, sourceIndex: 0))

        let forRoot = Node(kind: .for, left: nil, right: forCondition, token: .keyword(.for, sourceIndex: 0))

        XCTAssertEqual(node, forRoot)
    }
}
