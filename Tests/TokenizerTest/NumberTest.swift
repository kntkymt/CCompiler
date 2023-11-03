import XCTest
@testable import Tokenizer

final class NumberTest: XCTestCase {

    func testNumber() throws {
        let tokens = try tokenize(source: "5")
        XCTAssertEqual(
            tokens,
            [
                .number("5", sourceIndex: 0)
            ]
        )
    }

    func testNumberMultitoken() throws {
        let tokens = try tokenize(source: "123")
        XCTAssertEqual(
            tokens,
            [
                .number("123", sourceIndex: 0)
            ]
        )
    }
}
