import XCTest
@testable import Parser
import Tokenizer

final class MultiStatementTest: XCTestCase {

    func test2Statement() throws {
        let nodes = try parse(tokens: [
            .number("1", sourceIndex: 0),
            .reserved(.semicolon, sourceIndex: 1),
            .number("2", sourceIndex: 2),
            .reserved(.semicolon, sourceIndex: 3),
        ])

        XCTAssertEqual(
            nodes,
            [
                Node(kind: .number, left: nil, right: nil, token: .number("1", sourceIndex: 0)),
                Node(kind: .number, left: nil, right: nil, token: .number("2", sourceIndex: 2)),
            ]
        )
    }
}
