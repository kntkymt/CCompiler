import XCTest
@testable import Tokenizer

final class TokenizerTest: XCTestCase {

    func testNumber() throws {
        let tokens = try tokenize("5")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "5")
            ]
        )
    }

    func testNumberMultitoken() throws {
        let tokens = try tokenize("123")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "123")
            ]
        )
    }

    func testIgnoreSpaces() throws {
        let tokens = try tokenize("1 +   23")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "1"),
                Token(kind: .add, value: "+"),
                Token(kind: .number, value: "23")
            ]
        )
    }

    func testFailUnknownToken() throws {
        do {
            _ = try tokenize("1 ^")
        } catch let error as TokenizeError {
            XCTAssertEqual(error, TokenizeError.unknownToken)
        }
    }
}
