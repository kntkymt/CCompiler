import XCTest
@testable import Tokenizer

final class KeywordsTest: XCTestCase {

    func testReturn() throws {
        let source = "return"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.return), sourceIndex: 0)
            ]
        )
    }

    func testReturn2() throws {
        let source = "return 2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.return), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .number("2"), sourceIndex: 7)
            ]
        )
    }

    func testReturn3() throws {
        let source = "return;"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.return), sourceIndex: 0),
                Token(kind: .reserved(.semicolon), sourceIndex: 6)
            ]
        )
    }

    func testReturnSimularIdentifier() throws {
        let source = "returnX"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .identifier("returnX"), sourceIndex: 0)
            ]
        )
    }

    func testReturnSimularIdentifier2() throws {
        let source = "return2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .identifier("return2"), sourceIndex: 0)
            ]
        )
    }

    func testIf() throws {
        let source = "if(1)else 2"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.if), sourceIndex: 0),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 2),
                Token(kind: .number("1"), sourceIndex: 3),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 4),
                Token(kind: .keyword(.else), trailingTrivia: " ", sourceIndex: 5),
                Token(kind: .number("2"), sourceIndex: 10)
            ]
        )
    }

    func testWhile() throws {
        let source = "while(1)"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.while), sourceIndex: 0),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 5),
                Token(kind: .number("1"), sourceIndex: 6),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 7),
            ]
        )
    }

    func testFor() throws {
        let source = "for(1;2;3)"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.for), sourceIndex: 0),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 3),
                Token(kind: .number("1"), sourceIndex: 4),
                Token(kind: .reserved(.semicolon), sourceIndex: 5),
                Token(kind: .number("2"), sourceIndex: 6),
                Token(kind: .reserved(.semicolon), sourceIndex: 7),
                Token(kind: .number("3"), sourceIndex: 8),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 9),
            ]
        )
    }

    func testSizeOf() throws {
        let source = "sizeof(1)"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .keyword(.sizeof), sourceIndex: 0),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 6),
                Token(kind: .number("1"), sourceIndex: 7),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 8),
            ]
        )
    }
}
