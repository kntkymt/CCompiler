import XCTest
@testable import CCompilerCore

final class CompileErrorTest: XCTestCase {

    func testInvalidSyntax1() throws {
        do {
            _ = try compile("5 ++")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 3))
        }
    }

    func testInvalidSyntax2() throws {
        do {
            _ = try compile("")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testInvalidSyntax3() throws {
        do {
            _ = try compile("5 +")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 3))
        }
    }

    func testInvalidToken() throws {
        do {
            _ = try compile("5     ^")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidToken(index: 6))
        }
    }
}
