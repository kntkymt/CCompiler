import XCTest
@testable import Tokenizer

final class TokenizeErrorTest: XCTestCase {

    func testFailUnknownToken() throws {
        do {
            _ = try tokenize(source: "1 ^")
        } catch let error as TokenizeError {
            XCTAssertEqual(error, TokenizeError.unknownToken(index: 2))
        }
    }
}
