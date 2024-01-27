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
                        .endOfFile
                    ]
                )
            ).stmt()

            XCTFail()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 3)))
        }
    }

    func testInvalidPosition2() throws {
        do {
            _ = try Parser(
                tokens: buildTokens(
                    kinds: [
                        .number("1"),
                        .reserved(.add),
                        .reserved(.div),
                        .number("2"),
                        .reserved(.semicolon),
                        .endOfFile
                    ]
                )
            ).stmt()

            XCTFail()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 3)))
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
                        .endOfFile
                    ]
                )
            ).stmt()

            XCTFail()
        } catch let error as ParseError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 4)))
        }
    }
}
