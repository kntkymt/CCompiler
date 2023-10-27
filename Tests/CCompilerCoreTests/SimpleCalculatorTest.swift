import XCTest
@testable import CCompilerCore

final class SimpleCalculatorTest: XCTestCase {

    func testExample1() throws {
        let source = """
5+20-4
"""

        let compiled = compile(source)
        XCTAssertEqual(
            compiled,
"""
.globl _main
_main:
    mov w0, #5
    add w0, w0, #20
    sub w0, w0, #4
    ret

"""
        )
    }

    func testExample2() throws {
        let source = """
100+2-2+350
"""

        let compiled = compile(source)
        XCTAssertEqual(
            compiled,
"""
.globl _main
_main:
    mov w0, #100
    add w0, w0, #2
    sub w0, w0, #2
    add w0, w0, #350
    ret

"""
        )
    }
}
