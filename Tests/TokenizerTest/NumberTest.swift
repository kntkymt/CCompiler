import XCTest
@testable import Tokenizer

final class NumberTest: XCTestCase {

    func testNumber() throws {
        let source = "5"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("5"), sourceIndex: 0)
            ]
        )
    }

    func testNumberMultitoken() throws {
        let source = "123"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("123"), sourceIndex: 0)
            ]
        )
    }
}
