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
                Token(kind: .number("1"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .reserved(.add), trailingTrivia: "   ", sourceIndex: 2),
                Token(kind: .number("23"), sourceIndex: 6)
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
                Token(kind: .number("1"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .reserved(.add), trailingTrivia: "  ", sourceIndex: 2),
                Token(kind: .number("23"), sourceIndex: 5)
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
                Token(kind: .number("1"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 2),
                Token(kind: .number("23"), leadingTrivia: "\n", sourceIndex: 4)
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
                Token(kind: .number("1"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .reserved(.add), trailingTrivia: " // 234 ", sourceIndex: 2),
                Token(kind: .number("23"), leadingTrivia: "\n ", sourceIndex: 13)
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
                Token(kind: .number("1"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .reserved(.add), trailingTrivia: " /* 234 */ ", sourceIndex: 2),
                Token(kind: .number("23"), sourceIndex: 14)
            ]
        )
    }
}
