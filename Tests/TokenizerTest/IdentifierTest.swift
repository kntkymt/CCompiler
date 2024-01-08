import XCTest
@testable import Tokenizer

final class IdentifierTest: XCTestCase {

    func testIdentifier() throws {
        let source = "a"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("a"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                )
            ]
        )
    }

    func testIdentifierAdd() throws {
        let source = "a+b"
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
                    kind: .reserved(.add),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .identifier("b"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 3), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }

    func testIdentifierMulti() throws {
        let source = "ab"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("ab"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 3))
                )
            ]
        )
    }

    func testIdentifierMulti2() throws {
        let source = "ab hoge"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("ab"),
                    trailingTrivia: " ",
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 3))
                ),
                Token(
                    kind: .identifier("hoge"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 8))
                )
            ]
        )
    }

    func testIdentifierUpper() throws {
        let source = "AB"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("AB"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 3))
                )
            ]
        )
    }

    func testIdentifierNumber() throws {
        let source = "A2"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("A2"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 3))
                )
            ]
        )
    }

    func testIdentifierUnderScore() throws {
        let source = "_"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .identifier("_"), 
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                )
            ]
        )
    }

    func testIdentifierNotAlphabet() throws {
        do {
            _ = try Tokenizer(source: "あ").tokenize()
        } catch let error as TokenizeError {
            XCTAssertEqual(error, .unknownToken(location: SourceLocation(line: 1, column: 1)))
        }
    }
}
