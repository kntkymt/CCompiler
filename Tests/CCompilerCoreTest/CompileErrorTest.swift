import XCTest
@testable import CCompilerCore
import Tokenizer

final class CompileErrorTest: XCTestCase {

    func testInvalidSyntax1() throws {
        do {
            _ = try compile("int main(){5 ++}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 16)))
        }
    }

    func testInvalidSyntax2() throws {
        do {
            _ = try compile("main(){5++}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 1)))
        }
    }

    func testInvalidSyntax3() throws {
        do {
            _ = try compile("int main(){5 +}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 15)))
        }
    }

    func testInvalidSyntax4() throws {
        do {
            _ = try compile("int main(){+}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax(location: SourceLocation(line: 1, column: 13)))
        }
    }

    func testInvalidToken() throws {
        do {
            _ = try compile("int main(){5     ^}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidToken(location: SourceLocation(line: 1, column: 18)))
        }
    }

    func testNoSuchVariable() throws {
        do {
            _ = try compile("int main(){a = 0;}")
        } catch let error as CompileError {
            XCTAssertEqual(error, .noSuchVariable(variableName: "a", location: SourceLocation(line: 1, column: 12)))
        }
    }
}
