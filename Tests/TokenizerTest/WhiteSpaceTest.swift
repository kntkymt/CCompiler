import XCTest
@testable import Tokenizer

final class WhiteSpaceTest: XCTestCase {

    func testIgnoreSpaces() throws {
        let tokens = try tokenize(source: "1 +   23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 6)
            ]
        )
    }

    func testIgnoreTab() throws {
        let tokens = try tokenize(source: "1 +  23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 5)
            ]
        )
    }

    func testIgnoreBreak() throws {
        let tokens = try tokenize(source: "1 +\n23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 4)
            ]
        )
    }

    func testLineComment() throws {
        let tokens = try tokenize(source: "1 + // 234 \n 23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 13)
            ]
        )
    }

    func testBlockComment() throws {
        let tokens = try tokenize(source: "1 + /* 234 */ 23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 14)
            ]
        )
    }
}
