import XCTest
@testable import CCompilerCore

final class OneIntegerTest: XCTestCase {

    func testExample1() throws {
        let compiled = try compile("5")
        XCTAssertEqual(
            compiled,
"""
.globl _main
_main:
    mov w0, #5
    ret

"""
        )
    }

    func testExample2() throws {
        let compiled = try compile("123")
        XCTAssertEqual(
            compiled,
"""
.globl _main
_main:
    mov w0, #123
    ret

"""
        )
    }
}
