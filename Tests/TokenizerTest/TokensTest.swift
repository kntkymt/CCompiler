import XCTest
@testable import Tokenizer

final class TokensTest: XCTestCase {
    func testAdd() throws {
        let source = "1+2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testSub() throws {
        let source = "1-2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.sub),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testMul() throws {
        let source = "1*2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.mul),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testDiv() throws {
        let source = "1/2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.div),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testAnd() throws {
        let source = "&a"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .reserved(.and),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .identifier("a"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 3))
                )
            ]
        )
    }

    func testParenthesis() throws {
        let source = "(1)"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .reserved(.parenthesisLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .reserved(.parenthesisRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testSquares() throws {
        let source = "[1]"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .reserved(.squareLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .reserved(.squareRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testBraces() throws {
        let source = "{1;}"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .reserved(.braceLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .reserved(.semicolon),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .reserved(.braceRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testEqual() throws {
        let source = "1==2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.equal),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testNotEqual() throws {
        let source = "1!=2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.notEqual),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testGreaterThan() throws {
        let source = "1>2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.greaterThan),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testgreaterThanOrEqual() throws {
        let source = "1>=2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.greaterThanOrEqual),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testLessThan() throws {
        let source = "1<2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.lessThan),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testlessThanOrEqual() throws {
        let source = "1<=2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.lessThanOrEqual),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testAssign() throws {
        let source = "a=1"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("a"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.assign),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testSemicolon() throws {
        let source = "1;"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.semicolon),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 3))
                )
            ]
        )
    }

    func testComma() throws {
        let source = "1,2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.comma),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .integerLiteral("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }
}
