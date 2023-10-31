import XCTest
@testable import CCompilerCore

final class CompileErrorTest: XCTestCase {

    func testExample1() throws {
        do {
            _ = try compile("5 ++")
        } catch let error as CompileError {
            XCTAssertEqual(error, .invalidSyntax)
        }
    }
}
