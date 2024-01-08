import XCTest
@testable import Parser
import Tokenizer

final class ParseErrorTest: XCTestCase {

    func test2Operators() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .number("1"),
                        .reserved(.add),
                        .reserved(.semicolon),
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 3)))
        }
    }

    func testInvalidPosition() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .reserved(.mul),
                        .number("1"),
                        .reserved(.semicolon),
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 1)))
        }
    }

    func testInvalidPosition2() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .number("1"),
                        .reserved(.add),
                        .reserved(.mul),
                        .number("2"),
                        .reserved(.semicolon),
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 3)))
        }
    }

    func testEmpty() throws {
        do {
            _ = try Parser(tokens: []).parse()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 1)))
        }
    }

    func testNoSemicolon() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .number("1"),
                        .reserved(.add),
                        .number("2"),
                    ]
                )
            ).stmt()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 4)))
        }
    }
}
