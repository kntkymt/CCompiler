import XCTest
@testable import Tokenizer

final class KeywordsTest: XCTestCase {

    func testReturn() throws {
        let tokens = try tokenize(source: "return")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.return, sourceIndex: 0)
            ]
        )
    }

    func testReturn2() throws {
        let tokens = try tokenize(source: "return 2")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.return, sourceIndex: 0),
                .number("2", sourceIndex: 7)
            ]
        )
    }

    func testReturn3() throws {
        let tokens = try tokenize(source: "return;")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.return, sourceIndex: 0),
                .reserved(.semicolon, sourceIndex: 6)
            ]
        )
    }

    func testReturnSimularIdentifier() throws {
        let tokens = try tokenize(source: "returnX")
        XCTAssertEqual(
            tokens,
            [
                .identifier("returnX", sourceIndex: 0)
            ]
        )
    }

    func testReturnSimularIdentifier2() throws {
        let tokens = try tokenize(source: "return2")
        XCTAssertEqual(
            tokens,
            [
                .identifier("return2", sourceIndex: 0)
            ]
        )
    }
}
