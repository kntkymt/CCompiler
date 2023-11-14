import XCTest
@testable import Parser
import Tokenizer

final class ReturnTest: XCTestCase {

    func testReturn() throws {
        let node = try parse(tokens: [
            .keyword(.return, sourceIndex: 0),
            .number("2", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7),
        ])[0]

        let leftNode = Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 6))
        let returnNode = Node(kind: .return, left: leftNode, right: nil, token: .keyword(.return, sourceIndex: 0))

        XCTAssertEqual(node, returnNode)
    }

    func testReturnNoExpr() throws {
        do {
            _ = try parse(tokens: [
                .keyword(.return, sourceIndex: 0),
                .reserved(.semicolon, sourceIndex: 7),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 7))
        }
    }
}
