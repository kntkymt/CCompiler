import XCTest
@testable import Tokenizer

final class WhiteSpaceTest: XCTestCase {

    func testIgnoreSpaces() throws {
        let source = "1 +   23"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .number("1"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    trailingTrivia: "   ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("23"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 9))
                )
            ]
        )
    }

    func testIgnoreTab() throws {
        let source = "1 +  23"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .number("1"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    trailingTrivia: "  ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("23"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 8))
                )
            ]
        )
    }

    func testIgnoreBreak() throws {
        let source = "1 +\n23"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .number("1"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("23"),
                    leadingTrivia: "\n",
                    sourceRange: SourceRange(start: SourceLocation(line: 2, column: 1), end: SourceLocation(line: 2, column: 3))
                )
            ]
        )
    }

    func testLineComment() throws {
        let source = "1 + // 234 \n 23"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .number("1"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    trailingTrivia: " // 234 ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("23"),
                    leadingTrivia: "\n ",
                    sourceRange: SourceRange(start: SourceLocation(line: 2, column: 2), end: SourceLocation(line: 2, column: 4))
                )
            ]
        )
    }

    func testBlockComment() throws {
        let source = "1 + /* 234 */ 23"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .number("1"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .reserved(.add),
                    trailingTrivia: " /* 234 */ ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("23"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 15), end: SourceLocation(line: 1, column: 17))
                )
            ]
        )
    }
}
