import XCTest
@testable import Tokenizer

final class IdentifierTest: XCTestCase {

    func testIdentifier() throws {
        let tokens = try tokenize(source: "a")
        XCTAssertEqual(
            tokens,
            [
                .identifier("a", sourceIndex: 0)
            ]
        )
    }

    func testIdentifierAdd() throws {
        let tokens = try tokenize(source: "a+b")
        XCTAssertEqual(
            tokens,
            [
                .identifier("a", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .identifier("b", sourceIndex: 2)
            ]
        )
    }

    func testIdentifierMulti() throws {
        let tokens = try tokenize(source: "ab")
        XCTAssertEqual(
            tokens,
            [
                .identifier("ab", sourceIndex: 0)
            ]
        )
    }

    func testIdentifierMulti2() throws {
        let tokens = try tokenize(source: "ab hoge")
        XCTAssertEqual(
            tokens,
            [
                .identifier("ab", sourceIndex: 0),
                .identifier("hoge", sourceIndex: 3)
            ]
        )
    }

    func testIdentifierUpper() throws {
        let tokens = try tokenize(source: "AB")
        XCTAssertEqual(
            tokens,
            [
                .identifier("AB", sourceIndex: 0)
            ]
        )
    }

    func testIdentifierNumber() throws {
        let tokens = try tokenize(source: "A2")
        XCTAssertEqual(
            tokens,
            [
                .identifier("A2", sourceIndex: 0)
            ]
        )
    }

    func testIdentifierUnderScore() throws {
        let tokens = try tokenize(source: "_")
        XCTAssertEqual(
            tokens,
            [
                .identifier("_", sourceIndex: 0)
            ]
        )
    }

    func testIdentifierNotAlphabet() throws {
        do {
            _ = try tokenize(source: "あ")
        } catch let error as TokenizeError {
            XCTAssertEqual(error, .unknownToken(index: 0))
        }
    }
}
