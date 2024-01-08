import XCTest
@testable import Tokenizer

final class TokenizeErrorTest: XCTestCase {

    func testFailUnknownToken() throws {
        do {
            _ = try Tokenizer(source:  "1 ^").tokenize()
        } catch let error as TokenizeError {
            XCTAssertEqual(error, TokenizeError.unknownToken(location: SourceLocation(line: 1, column: 3)))
        }
    }
}
