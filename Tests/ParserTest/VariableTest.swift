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
            VariableDeclNode(type: TypeNode(typeToken: tokens[0]), identifierToken: tokens[1])
        )
    }

    func testDeclVariablePointer() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .reserved(.mul, sourceIndex: 3),
            .identifier("a", sourceIndex: 5),
            .reserved(.semicolon, sourceIndex: 6)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(type: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]), identifierToken: tokens[2])
        )
    }

    func testDeclVariablePointer2() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .reserved(.mul, sourceIndex: 3),
            .reserved(.mul, sourceIndex: 4),
            .identifier("a", sourceIndex: 6),
            .reserved(.semicolon, sourceIndex: 7)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(type: PointerTypeNode(referenceType: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]), pointerToken: tokens[2]) , identifierToken: tokens[3])
        )
    }

    func testDeclVariableArray() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .identifier("a", sourceIndex: 4),
            .reserved(.squareLeft, sourceIndex: 5),
            .number("4", sourceIndex: 6),
            .reserved(.squareRight, sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: ArrayTypeNode(
                    elementType: TypeNode(typeToken: tokens[0]),
                    squareLeftToken: tokens[2],
                    arraySizeToken: tokens[3],
                    squareRightToken: tokens[4]
                ),
                identifierToken: tokens[1]
            )
        )
    }

    func testDeclVariableArrayPointer() throws {
        let tokens: [Token] = [
            .type(.int, sourceIndex: 0),
            .reserved(.mul, sourceIndex: 3),
            .identifier("a", sourceIndex: 4),
            .reserved(.squareLeft, sourceIndex: 5),
            .number("4", sourceIndex: 6),
            .reserved(.squareRight, sourceIndex: 7),
            .reserved(.semicolon, sourceIndex: 8)
        ]
        let node = try Parser(tokens: tokens).stmt()

        XCTAssertEqual(
            node as! VariableDeclNode,
            VariableDeclNode(
                type: ArrayTypeNode(
                    elementType: PointerTypeNode(referenceType: TypeNode(typeToken: tokens[0]), pointerToken: tokens[1]),
                    squareLeftToken: tokens[3],
                    arraySizeToken: tokens[4],
                    squareRightToken: tokens[5]
                ),
                identifierToken: tokens[2]
            )
        )
    }
}
