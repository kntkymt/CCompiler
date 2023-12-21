import XCTest
@testable import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral() throws {
        let tokens = try tokenize(source: "\"aaaa\"")
        XCTAssertEqual(
            tokens,
            [
                .stringLiteral("aaaa", sourceIndex: 0)
            ]
        )
    }
}
