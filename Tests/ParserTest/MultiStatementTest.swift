import XCTest
@testable import Parser
import Tokenizer

final class MultiStatementTest: XCTestCase {

    func test2Statement() throws {
        let tokens: [Token] = [
            .number("1", sourceIndex: 0),
            .reserved(.semicolon, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3),
        ]
        let nodes = try parse(tokens: tokens)

        XCTAssertEqual(
            nodes as! [IntegerLiteralNode],
            [
                IntegerLiteralNode(token: tokens[0]),
                IntegerLiteralNode(token: tokens[2])
            ]
        )
    }
}
