import XCTest
@testable import Tokenizer

final class TokenSpecTest: XCTestCase {
    func testReserved() {
        for kind in ReservedKind.allCases {
            let spec = TokenSpec.reserved(kind)
            let token = Token(kind: .reserved(kind), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
            XCTAssert(spec ~= token)

            XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
            XCTAssertFalse(TokenSpec.integerLiteral ~= token)
            XCTAssertFalse(TokenSpec.stringLiteral ~= token)
            XCTAssertFalse(TokenSpec.identifier ~= token)
            XCTAssertFalse(TokenSpec.type ~= token)
            XCTAssertFalse(TokenSpec.endOfFile ~= token)
        }
    }

    func testKeywords() {
        for kind in KeywordKind.allCases {
            let spec = TokenSpec.keyword(kind)
            let token = Token(kind: .keyword(kind), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
            XCTAssert(spec ~= token)

            XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
            XCTAssertFalse(TokenSpec.integerLiteral ~= token)
            XCTAssertFalse(TokenSpec.stringLiteral ~= token)
            XCTAssertFalse(TokenSpec.identifier ~= token)
            XCTAssertFalse(TokenSpec.type ~= token)
            XCTAssertFalse(TokenSpec.endOfFile ~= token)
        }
    }

    func testIntegerLiteral() {
        let spec = TokenSpec.integerLiteral
        let token = Token(kind: .integerLiteral("1"), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
        XCTAssert(spec ~= token)

        XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
        XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
        XCTAssertFalse(TokenSpec.stringLiteral ~= token)
        XCTAssertFalse(TokenSpec.identifier ~= token)
        XCTAssertFalse(TokenSpec.type ~= token)
        XCTAssertFalse(TokenSpec.endOfFile ~= token)
    }

    func testStringLiteral() {
        let spec = TokenSpec.stringLiteral
        let token = Token(kind: .stringLiteral("a"), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
        XCTAssert(spec ~= token)

        XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
        XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
        XCTAssertFalse(TokenSpec.integerLiteral ~= token)
        XCTAssertFalse(TokenSpec.identifier ~= token)
        XCTAssertFalse(TokenSpec.type ~= token)
        XCTAssertFalse(TokenSpec.endOfFile ~= token)
    }

    func testIdentifier() {
        let spec = TokenSpec.identifier
        let token = Token(kind: .identifier("a"), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
        XCTAssert(spec ~= token)

        XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
        XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
        XCTAssertFalse(TokenSpec.integerLiteral ~= token)
        XCTAssertFalse(TokenSpec.stringLiteral ~= token)
        XCTAssertFalse(TokenSpec.type ~= token)
        XCTAssertFalse(TokenSpec.endOfFile ~= token)
    }

    func testType() {
        for kind in TypeKind.allCases {
            let spec = TokenSpec.type
            let token = Token(kind: .type(kind), sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
            XCTAssert(spec ~= token)

            XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
            XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
            XCTAssertFalse(TokenSpec.integerLiteral ~= token)
            XCTAssertFalse(TokenSpec.stringLiteral ~= token)
            XCTAssertFalse(TokenSpec.endOfFile ~= token)
        }
    }

    func testEndOfFile() {
        let spec = TokenSpec.endOfFile
        let token = Token(kind: .endOfFile, sourceRange: SourceRange(start: .startOfFile, end: .startOfFile))
        XCTAssert(spec ~= token)

        XCTAssertFalse(TokenSpec.reserved(.add) ~= token)
        XCTAssertFalse(TokenSpec.keyword(.if) ~= token)
        XCTAssertFalse(TokenSpec.integerLiteral ~= token)
        XCTAssertFalse(TokenSpec.stringLiteral ~= token)
        XCTAssertFalse(TokenSpec.type ~= token)
    }
}
