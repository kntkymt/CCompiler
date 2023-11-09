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
                .identifier("a", sourceIndex: 0),
                .identifier("b", sourceIndex: 1)
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
