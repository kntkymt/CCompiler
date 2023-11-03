import XCTest
@testable import Tokenizer

final class TokenizerTest: XCTestCase {

    func testNumber() throws {
        let tokens = try tokenize(source: "5")
        XCTAssertEqual(
            tokens,
            [
                .number("5", sourceIndex: 0)
            ]
        )
    }

    func testNumberMultitoken() throws {
        let tokens = try tokenize(source: "123")
        XCTAssertEqual(
            tokens,
            [
                .number("123", sourceIndex: 0)
            ]
        )
    }

    func testIgnoreSpaces() throws {
        let tokens = try tokenize(source: "1 +   23")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 2),
                .number("23", sourceIndex: 6)
            ]
        )
    }

    func testCalculateOperand() throws {
        let tokens = try tokenize(source: "1+2-3*4/5+(1+2)")
        XCTAssertEqual(
            tokens,
            [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .number("2", sourceIndex: 2),
                .reserved(.sub, sourceIndex: 3),
                .number("3", sourceIndex: 4),
                .reserved(.mul, sourceIndex: 5),
                .number("4", sourceIndex: 6),
                .reserved(.div, sourceIndex: 7),
                .number("5", sourceIndex: 8),
                .reserved(.add, sourceIndex: 9),
                .reserved(.parenthesisLeft, sourceIndex: 10),
                .number("1", sourceIndex: 11),
                .reserved(.add, sourceIndex: 12),
                .number("2", sourceIndex: 13),
                .reserved(.parenthesisRight, sourceIndex: 14)
            ]
        )
    }

    func testCompare() throws {
        try XCTContext.runActivity(named: "equal") { _ in
            let tokens = try tokenize(source: "1==2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.equal, sourceIndex: 1),
                    .number("2", sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "notEqual") { _ in
            let tokens = try tokenize(source: "1!=2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.notEqual, sourceIndex: 1),
                    .number("2", sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "greaterThan") { _ in
            let tokens = try tokenize(source: "1>2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.greaterThan, sourceIndex: 1),
                    .number("2", sourceIndex: 2)
                ]
            )
        }

        try XCTContext.runActivity(named: "greaterThanOrEqual") { _ in
            let tokens = try tokenize(source: "1>=2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.greaterThanOrEqual, sourceIndex: 1),
                    .number("2", sourceIndex: 3)
                ]
            )
        }

        try XCTContext.runActivity(named: "lessThan") { _ in
            let tokens = try tokenize(source: "1<2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.lessThan, sourceIndex: 1),
                    .number("2", sourceIndex: 2)
                ]
            )
        }

        try XCTContext.runActivity(named: "lessThanOrEqual") { _ in
            let tokens = try tokenize(source: "1<=2")
            XCTAssertEqual(
                tokens,
                [
                    .number("1", sourceIndex: 0),
                    .reserved(.lessThanOrEqual, sourceIndex: 1),
                    .number("2", sourceIndex: 3)
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
