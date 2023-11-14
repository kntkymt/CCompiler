import XCTest
@testable import Parser
import Tokenizer

final class WhileTest: XCTestCase {

    func testWhile() throws {
        let node = try parse(tokens: [
            .keyword(.while, sourceIndex: 0),
            .reserved(.parenthesisLeft, sourceIndex: 5),
            .number("1", sourceIndex: 6),
            .reserved(.parenthesisRight, sourceIndex: 7),
            .number("2", sourceIndex: 8),
            .reserved(.semicolon, sourceIndex: 9)
        ])[0]

        let condition = Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 6))
        let statement = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 8))
        let whileNode = Node(kind: .while, left: condition, right: statement, token: .keyword(.while, sourceIndex: 0))

        XCTAssertEqual(node, whileNode)
    }

    func testWhileNoExpr() throws {
        do {
            _ = try parse(tokens: [
                .keyword(.while, sourceIndex: 0),
                .reserved(.parenthesisLeft, sourceIndex: 5),
                .number("1", sourceIndex: 6),
                .reserved(.parenthesisRight, sourceIndex: 7),
                .reserved(.semicolon, sourceIndex: 8)
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 8))
        }
    }
}
