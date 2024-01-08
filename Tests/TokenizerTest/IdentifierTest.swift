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
                Token(kind: .identifier("a"), sourceIndex: 0)
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
                Token(kind: .identifier("a"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .identifier("b"), sourceIndex: 2)
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
                Token(kind: .identifier("ab"), sourceIndex: 0)
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
                Token(kind: .identifier("ab"), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .identifier("hoge"), sourceIndex: 3)
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
                Token(kind: .identifier("AB"), sourceIndex: 0)
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
                Token(kind: .identifier("A2"), sourceIndex: 0)
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
                Token(kind: .identifier("_"), sourceIndex: 0)
            ]
        )
    }

    func testIdentifierNotAlphabet() throws {
        do {
            _ = try Tokenizer(source: "あ").tokenize()
        } catch let error as TokenizeError {
            XCTAssertEqual(error, .unknownToken(index: 0))
        }
    }
}
