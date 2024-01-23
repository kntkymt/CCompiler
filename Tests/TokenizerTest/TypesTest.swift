import XCTest
@testable import Tokenizer

final class TypesTest: XCTestCase {

    func testInt() throws {
        let source = "int a"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .type(.int),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .identifier("a"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 6))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 6))
                )
            ]
        )
    }

    func testInt2() throws {
        let source = "inta"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("inta"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 5), end: SourceLocation(line: 1, column: 5))
                )
            ]
        )
    }

    func testChar() throws {
        let source = "char a"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .type(.char),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 5))
                ),
                Token(
                    kind: .identifier("a"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 7))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 7), end: SourceLocation(line: 1, column: 7))
                )
            ]
        )
    }

    func testChar2() throws {
        let source = "chara"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("chara"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 6))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 6), end: SourceLocation(line: 1, column: 6))
                )
            ]
        )
    }
}
