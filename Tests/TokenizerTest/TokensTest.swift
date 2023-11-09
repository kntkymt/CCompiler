import XCTest
@testable import Tokenizer

final class TokensTest: XCTestCase {
    func testAdd() throws {
        let tokens = try tokenize(source: "1+2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testSub() throws {
        let tokens = try tokenize(source: "1-2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.sub, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testMul() throws {
        let tokens = try tokenize(source: "1*2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.mul, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testDiv() throws {
        let tokens = try tokenize(source: "1/2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.div, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testparenthesis() throws {
        let tokens = try tokenize(source: "(1)")
        XCTAssertEqual(
            tokens,
            [
                .reserved(.parenthesisLeft, sourceIndex: 0),
                .number("1", sourceIndex: 1),
                .reserved(.parenthesisRight, sourceIndex: 2)
            ]
        )
    }

    func testEqual() throws {
        let tokens = try tokenize(source: "1==2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.equal, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ]
        )
    }

    func testNotEqual() throws {
        let tokens = try tokenize(source: "1!=2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.notEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ]
        )
    }

    func testGreaterThan() throws {
        let tokens = try tokenize(source: "1>2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.greaterThan, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testgreaterThanOrEqual() throws {
        let tokens = try tokenize(source: "1>=2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.greaterThanOrEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ]
        )
    }

    func testLessThan() throws {
        let tokens = try tokenize(source: "1<2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.lessThan, sourceIndex: 1),
                .number("2", sourceIndex: 2)
            ]
        )
    }

    func testlessThanOrEqual() throws {
        let tokens = try tokenize(source: "1<=2")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.lessThanOrEqual, sourceIndex: 1),
                .number("2", sourceIndex: 3)
            ]
        )
    }

    func testAssign() throws {
        let tokens = try tokenize(source: "a=1")
        XCTAssertEqual(
            tokens,
            [
                .identifier("a", sourceIndex: 0),
                .reserved(.assign, sourceIndex: 1),
                .number("1", sourceIndex: 2),
            ]
        )
    }

    func testSemicolon() throws {
        let tokens = try tokenize(source: "1;")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.semicolon, sourceIndex: 1),
            ]
        )
    }
}
