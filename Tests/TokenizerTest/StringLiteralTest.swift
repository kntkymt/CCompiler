import XCTest
@testable import Tokenizer

final class StringLiteralTest: XCTestCase {

    func testStringLiteral() throws {
        let source = "\"aaaa\""
        let tokens = try Tokenizer(source: source).tokenize()

        // FIXME: StringLiteralの両端のクオーテーションをどうするか
        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, "aaaa")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .stringLiteral("aaaa"), sourceIndex: 0)
            ]
        )
    }
}
