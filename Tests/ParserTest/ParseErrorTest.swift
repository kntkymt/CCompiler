import XCTest
@testable import Parser
import Tokenizer

final class ParseErrorTest: XCTestCase {

    func test2Operators() throws {
        do {
            _ = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .reserved(.semicolon, sourceIndex: 2),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 2))
        }
    }

    func testInvalidPosition() throws {
        do {
            _ = try parse(tokens: [
                .reserved(.mul, sourceIndex: 0),
                .number("1", sourceIndex: 1),
                .reserved(.semicolon, sourceIndex: 2),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testInvalidPosition2() throws {
        do {
            _ = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .reserved(.mul, sourceIndex: 2),
                .number("2", sourceIndex: 3),
                .reserved(.semicolon, sourceIndex: 4),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 2))
        }
    }

    func testEmpty() throws {
        do {
            _ = try parse(tokens: [])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testNoSemicolon() throws {
        do {
            _ = try parse(tokens: [
                .number("1", sourceIndex: 0),
                .reserved(.add, sourceIndex: 1),
                .number("2", sourceIndex: 2),
            ])
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(index: 3))
        }
    }
}
