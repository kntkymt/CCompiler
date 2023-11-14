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

    func testIf() throws {
        let tokens = try tokenize(source: "if(1)else 2")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.if, sourceIndex: 0),
                .reserved(.parenthesisLeft, sourceIndex: 2),
                .number("1", sourceIndex: 3),
                .reserved(.parenthesisRight, sourceIndex: 4),
                .keyword(.else, sourceIndex: 5),
                .number("2", sourceIndex: 10)
            ]
        )
    }

    func testWhile() throws {
        let tokens = try tokenize(source: "while(1)")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.while, sourceIndex: 0),
                .reserved(.parenthesisLeft, sourceIndex: 5),
                .number("1", sourceIndex: 6),
                .reserved(.parenthesisRight, sourceIndex: 7),
            ]
        )
    }

    func testFor() throws {
        let tokens = try tokenize(source: "for(1;2;3)")
        XCTAssertEqual(
            tokens,
            [
                .keyword(.for, sourceIndex: 0),
                .reserved(.parenthesisLeft, sourceIndex: 3),
                .number("1", sourceIndex: 4),
                .reserved(.semicolon, sourceIndex: 5),
                .number("2", sourceIndex: 6),
                .reserved(.semicolon, sourceIndex: 7),
                .number("3", sourceIndex: 8),
                .reserved(.parenthesisRight, sourceIndex: 9),
            ]
        )
    }
}
