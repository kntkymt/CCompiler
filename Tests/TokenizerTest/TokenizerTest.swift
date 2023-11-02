import XCTest
@testable import Tokenizer

final class TokenizerTest: XCTestCase {

    func testNumber() throws {
        let tokens = try tokenize("5")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "5", sourceIndex: 0)
            ]
        )
    }

    func testNumberMultitoken() throws {
        let tokens = try tokenize("123")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "123", sourceIndex: 0)
            ]
        )
    }

    func testIgnoreSpaces() throws {
        let tokens = try tokenize("1 +   23")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .add, value: "+", sourceIndex: 2),
                Token(kind: .number, value: "23", sourceIndex: 6)
            ]
        )
    }

    func testCalculateOperand() throws {
        let tokens = try tokenize("1+2-3*4/5+(1+2)")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number, value: "1", sourceIndex: 0),
                Token(kind: .add, value: "+", sourceIndex: 1),
                Token(kind: .number, value: "2", sourceIndex: 2),
                Token(kind: .sub, value: "-", sourceIndex: 3),
                Token(kind: .number, value: "3", sourceIndex: 4),
                Token(kind: .mul, value: "*", sourceIndex: 5),
                Token(kind: .number, value: "4", sourceIndex: 6),
                Token(kind: .div, value: "/", sourceIndex: 7),
                Token(kind: .number, value: "5", sourceIndex: 8),
                Token(kind: .add, value: "+", sourceIndex: 9),
                Token(kind: .parenthesisLeft, value: "(", sourceIndex: 10),
                Token(kind: .number, value: "1", sourceIndex: 11),
                Token(kind: .add, value: "+", sourceIndex: 12),
                Token(kind: .number, value: "2", sourceIndex: 13),
                Token(kind: .parenthesisRight, value: ")", sourceIndex: 14),
            ]
        )
    }

    func testFailUnknownToken() throws {
        do {
            _ = try tokenize("1 ^")
        } catch let error as TokenizeError {
            XCTAssertEqual(error, TokenizeError.unknownToken(index: 2))
        }
    }
}
