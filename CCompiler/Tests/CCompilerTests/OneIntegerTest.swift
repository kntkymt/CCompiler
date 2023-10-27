import XCTest
@testable import CCompiler

final class OneIntegerTests: XCTestCase {

    func testExample1() throws {
        let compiled = compile("5")
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
        let compiled = compile("123")
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
