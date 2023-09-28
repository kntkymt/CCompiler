import XCTest
@testable import CCompiler

final class CCompilerTests: XCTestCase {

    func testExample() throws {
        let compiled = compile()
        XCTAssertEqual(
            compiled,
"""
.globl    _main
_main:
    mov    w0, #42
    ret
"""
        )
    }

}
