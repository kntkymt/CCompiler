import XCTest
@testable import Tokenizer

final class TypesTest: XCTestCase {

    func testInt() throws {
        let source = "int a"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .type(.int), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .identifier("a"), sourceIndex: 4)
            ]
        )
    }

    func testInt2() throws {
        let source = "inta"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .identifier("inta"), sourceIndex: 0)
            ]
        )
    }

    func testChar() throws {
        let source = "char a"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .type(.char), trailingTrivia: " ", sourceIndex: 0),
                Token(kind: .identifier("a"), sourceIndex: 5)
            ]
        )
    }

    func testChar2() throws {
        let source = "chara"
        let tokens = try tokenize(source: source)

        XCTAssertEqual(tokens.reduce("") { $0 + $1.description }, source)
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .identifier("chara"), sourceIndex: 0)
            ]
        )
    }
}
