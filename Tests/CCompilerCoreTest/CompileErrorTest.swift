import XCTest
@testable import CCompilerCore

final class CompileErrorTest: XCTestCase {

    func testInvalidSyntax1() throws {
        do {
            _ = try compile("main(){5 ++}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 11))
        }
    }

    func testInvalidSyntax2() throws {
        do {
            _ = try compile("a = 0")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 2))
        }
    }

    func testInvalidSyntax3() throws {
        do {
            _ = try compile("main(){5 +}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 10))
        }
    }

    func testInvalidSyntax4() throws {
        do {
            _ = try compile("main(){+}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 8))
        }
    }

    func testInvalidToken() throws {
        do {
            _ = try compile("main(){5     ^}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidToken(index: 13))
        }
    }
}
