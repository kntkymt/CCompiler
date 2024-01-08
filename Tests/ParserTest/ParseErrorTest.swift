import XCTest
@testable import Parser
import Tokenizer

final class ParseErrorTest: XCTestCase {

    func test2Operators() throws {
        do {
            _ = try Parser(tokens: [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .reserved(.semicolon), sourceIndex: 2),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 2))
        }
    }

    func testInvalidPosition() throws {
        do {
            _ = try Parser(tokens: [
                Token(kind: .reserved(.mul), sourceIndex: 0),
                Token(kind: .number("1"), sourceIndex: 1),
                Token(kind: .reserved(.semicolon), sourceIndex: 2),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testInvalidPosition2() throws {
        do {
            _ = try Parser(tokens: [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .reserved(.mul), sourceIndex: 2),
                Token(kind: .number("2"), sourceIndex: 3),
                Token(kind: .reserved(.semicolon), sourceIndex: 4),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 2))
        }
    }

    func testEmpty() throws {
        do {
            _ = try Parser(tokens: []).parse()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testNoSemicolon() throws {
        do {
            _ = try Parser(tokens: [
                Token(kind: .number("1"), sourceIndex: 0),
                Token(kind: .reserved(.add), sourceIndex: 1),
                Token(kind: .number("2"), sourceIndex: 2),
            ]).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 3))
        }
    }
}
