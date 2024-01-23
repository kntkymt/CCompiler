import XCTest
@testable import Tokenizer

final class KeywordsTest: XCTestCase {

    func testReturn() throws {
        let source = "return"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.return),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 7))
                )
            ]
        )
    }

    func testReturn2() throws {
        let source = "return 2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.return),
                    trailingTrivia: " ", 
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .number("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 9))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 9), end: SourceLocation(line: 1, column: 9))
                )
            ]
        )
    }

    func testReturn3() throws {
        let source = "return;"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.return),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .reserved(.semicolon),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 8))
                )
            ]
        )
    }

    func testReturnSimularIdentifier() throws {
        let source = "returnX"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("returnX"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 8))
                )
            ]
        )
    }

    func testReturnSimularIdentifier2() throws {
        let source = "return2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("return2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 8))
                )
            ]
        )
    }

    func testIf() throws {
        let source = "if(1)else 2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.if),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .reserved(.parenthesisLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .number("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .reserved(.parenthesisRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 6))
                ),
                Token(
                    kind: .keyword(.else),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 10))
                ),
                Token(
                    kind: .number("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 11), end: SourceLocation(line: 1, column: 12))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 12), end: SourceLocation(line: 1, column: 12))
                )
            ]
        )
    }

    func testWhile() throws {
        let source = "while(1)"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.while),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 6))
                ),
                Token(
                    kind: .reserved(.parenthesisLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .number("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .reserved(.parenthesisRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 9))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 9), end: SourceLocation(line: 1, column: 9))
                )
            ]
        )
    }

    func testFor() throws {
        let source = "for(1;2;3)"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.for),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .reserved(.parenthesisLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .number("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 6))
                ),
                Token(
                    kind: .reserved(.semicolon),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .number("2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .reserved(.semicolon),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 9))
                ),
                Token(
                    kind: .number("3"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 9), end: SourceLocation(line: 1, column: 10))
                ),
                Token(
                    kind: .reserved(.parenthesisRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 10), end: SourceLocation(line: 1, column: 11))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 11), end: SourceLocation(line: 1, column: 11))
                )
            ]
        )
    }

    func testSizeOf() throws {
        let source = "sizeof(1)"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .keyword(.sizeof),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .reserved(.parenthesisLeft),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 8))
                ),
                Token(
                    kind: .number("1"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 8), end: SourceLocation(line: 1, column: 9))
                ),
                Token(
                    kind: .reserved(.parenthesisRight),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 9), end: SourceLocation(line: 1, column: 10))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 10), end: SourceLocation(line: 1, column: 10))
                )
            ]
        )
    }
}
