import XCTest
@testable import Tokenizer

final class IntegerLiteralTest: XCTestCase {

    func testIntegerLiteral() throws {
        let source = "5"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("5"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 2))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 2), end: SourceLocation(line: 1, column: 2))
                )
            ]
        )
    }

    func testIntegerLiteralMulti() throws {
        let source = "123"
        let tokens = try Tokenizer(source: source).tokenize()

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: .integerLiteral("123"),
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 1), end: SourceLocation(line: 1, column: 4))
                ),
                Token(
                    kind: .endOfFile,
                    sourceRange: SourceRange(start: SourceLocation(line: 1, column: 4), end: SourceLocation(line: 1, column: 4))
                )
            ]
        )
    }
}
