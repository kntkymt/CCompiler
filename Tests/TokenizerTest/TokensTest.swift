import XCTest
@testable import Tokenizer

final class TokensTest: XCTestCase {
    func testAdd() throws {
        let source = "1+2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testSub() throws {
        let source = "1-2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.sub), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testMul() throws {
        let source = "1*2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.mul), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testDiv() throws {
        let source = "1/2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.div), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testAnd() throws {
        let source = "&a"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .reserved(.and), sourceIndex: 0),
                Token(kind: .identifier("a"), sourceIndex: 1)
            ]
        )
    }

    func testParenthesis() throws {
        let source = "(1)"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 0),
                Token(kind: .number("1"), sourceIndex: 1),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 2)
            ]
        )
    }

    func testSquares() throws {
        let source = "[1]"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .reserved(.squareLeft), sourceIndex: 0),
                Token(kind: .number("1"), sourceIndex: 1),
                Token(kind: .reserved(.squareRight), sourceIndex: 2)
            ]
        )
    }

    func testBraces() throws {
        let source = "{1;}"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .reserved(.braceLeft), sourceIndex: 0),
                Token(kind: .number("1"), sourceIndex: 1),
                Token(kind: .reserved(.semicolon), sourceIndex: 2),
                      Token(kind: .reserved(.braceRight), sourceIndex: 3)
            ]
        )
    }

    func testEqual() throws {
        let source = "1==2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.equal), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 3)
            ]
        )
    }

    func testNotEqual() throws {
        let source = "1!=2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.notEqual), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 3)
            ]
        )
    }

    func testGreaterThan() throws {
        let source = "1>2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.greaterThan), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testgreaterThanOrEqual() throws {
        let source = "1>=2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.greaterThanOrEqual), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 3)
            ]
        )
    }

    func testLessThan() throws {
        let source = "1<2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.lessThan), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }

    func testlessThanOrEqual() throws {
        let source = "1<=2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.lessThanOrEqual), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 3)
            ]
        )
    }

    func testAssign() throws {
        let source = "a=1"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .identifier("a"), sourceIndex: 0),
                Token(kind: .reserved(.assign), sourceIndex: 1),
                Token(kind: .number("1"), sourceIndex: 2),
            ]
        )
    }

    func testSemicolon() throws {
        let source = "1;"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.semicolon), sourceIndex: 1),
            ]
        )
    }

    func testComma() throws {
        let source = "1,2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.comma), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2)
            ]
        )
    }
}
