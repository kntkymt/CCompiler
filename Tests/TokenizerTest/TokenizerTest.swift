import XCTest
@testable import Tokenizer

final class TokenizerTest: XCTestCase {

    func testNumber() throws {
        let tokens = try tokenize(source: "5")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("5"), sourceIndex: 0)
            ]
        )
    }

    func testNumberMultitoken() throws {
        let tokens = try tokenize(source: "123")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("123"), sourceIndex: 0)
            ]
        )
    }

    func testIgnoreSpaces() throws {
        let tokens = try tokenize(source: "1 +   23")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 2),
                Token(kind: .number("23"), sourceIndex: 6)
            ]
        )
    }

    func testCalculateOperand() throws {
        let tokens = try tokenize(source: "1+2-3*4/5+(1+2)")
        XCTAssertEqual(
            tokens,
            [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2),
                Token(kind: .reserved(.sub), sourceIndex: 3),
                Token(kind: .number("3"), sourceIndex: 4),
                Token(kind: .reserved(.mul), sourceIndex: 5),
                Token(kind: .number("4"), sourceIndex: 6),
                Token(kind: .reserved(.div), sourceIndex: 7),
                Token(kind: .number("5"), sourceIndex: 8),
                Token(kind: .reserved(.add), sourceIndex: 9),
                Token(kind: .reserved(.parenthesisLeft), sourceIndex: 10),
                Token(kind: .number("1"), sourceIndex: 11),
                Token(kind: .reserved(.add), sourceIndex: 12),
                Token(kind: .number("2"), sourceIndex: 13),
                Token(kind: .reserved(.parenthesisRight), sourceIndex: 14)
            ]
        )
    }

    func testCompare() throws {
        try XCTContext.runActivity(named: "equal") { _ in
            let tokens = try tokenize(source: "1==2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.equal), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "notEqual") { _ in
            let tokens = try tokenize(source: "1!=2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.notEqual), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "greaterThan") { _ in
            let tokens = try tokenize(source: "1>2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.greaterThan), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 2)
                ]
            )
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            let tokens = try tokenize(source: "1>=2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.greaterThanOrEqual), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "lessThan") { _ in
            let tokens = try tokenize(source: "1<2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.lessThan), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 2)
                ]
            )
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            let tokens = try tokenize(source: "1<=2")
            XCTAssertEqual(
                tokens,
                [
                    Token(kind: .number("1"), sourceIndex: 0),
                    Token(kind: .reserved(.lessThanOrEqual), sourceIndex: 1),
                    Token(kind: .number("2"), sourceIndex: 3)
                ]
            )
        }
    }

    func testFailUnknownToken() throws {
        do {
            _ = try tokenize(source: "1 ^")
        } catch let error as TokenizeError {
            XCTAssertEqual(error, TokenizeError.unknownToken(index: 2))
        }
    }
}
