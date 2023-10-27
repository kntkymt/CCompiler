import XCTest
@testable import CCompiler

final class CCompilerTests: XCTestCase {

    func testExample() throws {
        let compiled = compile(int: 123)
        XCTAssertEqual(
            compiled,
"""
.globl    _main
_main:
    mov    w0, #123
    ret
"""
        )
    }

}
