import XCTest
@testable import CCompilerCore

final class CompileErrorTest: XCTestCase {

    func testInvalidSyntax1() throws {
        do {
            _ = try compile("int main(){5 ++}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 15))
        }
    }

    func testInvalidSyntax2() throws {
        do {
            _ = try compile("main(){5++}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 0))
        }
    }

    func testInvalidSyntax3() throws {
        do {
            _ = try compile("int main(){5 +}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 14))
        }
    }

    func testInvalidSyntax4() throws {
        do {
            _ = try compile("int main(){+}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(index: 12))
        }
    }

    func testInvalidToken() throws {
        do {
            _ = try compile("int main(){5     ^}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidToken(index: 17))
        }
    }

    func testNoSuchVariable() throws {
        do {
            _ = try compile("int main(){a = 0;}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .noSuchVariable(variableName: "a", index: 11))
        }
    }
}
