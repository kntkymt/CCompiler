import XCTest
@testable import Parser
import Tokenizer

final class VariableTest: XCTestCase {

    func testDeclVariable() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .identifier("a", sourceIndex: 4),
            .reserved(.semicolon, sourceIndex: 5)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(typeToken: tokens[0], identifierToken: tokens[1])
        )
    }
}
