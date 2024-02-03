import XCTest
@testable import Optimizer
import Generator

final class RemoveImmediatePushPopPathTest: XCTestCase {

    func testRemoved() {
        let instructions: [AsmRepresent.Instruction] = [
            .movi(dst: .x0, immediate: 10),
            .push(src: .x0),
            .pop(dst: .x0),
            .ret
        ]

        let result = RemoveImmediatePushPopPath().optimize(instructions: instructions)
        let expected: [AsmRepresent.Instruction] = [
            instructions[0],
            instructions[3]
        ]

        XCTAssertEqual(result, expected)
    }

    func testNotRemoved() {
        let instructions: [AsmRepresent.Instruction] = [
            .movi(dst: .x0, immediate: 10),
            .push(src: .x0),
            .add(dst: .x0, src1: .x1, src2: .x0),
            .mov(dst: .x1, src: .x0),
            .pop(dst: .x0),
            .ret
        ]

        let result = RemoveImmediatePushPopPath().optimize(instructions: instructions)
        let expected: [AsmRepresent.Instruction] = instructions

        XCTAssertEqual(result, expected)
    }
}
