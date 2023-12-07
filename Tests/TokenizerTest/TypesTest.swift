import XCTest
@testable import Tokenizer

final class TypesTest: XCTestCase {

    func testInt() throws {
        let tokens = try tokenize(source: "int a")
        XCTAssertEqual(
            tokens,
            [
                .type(.int, sourceIndex: 0),
                .identifier("a", sourceIndex: 4)
            ]
        )
    }

    func testInt2() throws {
        let tokens = try tokenize(source: "inta")
        XCTAssertEqual(
            tokens,
            [
                .identifier("inta", sourceIndex: 0)
            ]
        )
    }
}
