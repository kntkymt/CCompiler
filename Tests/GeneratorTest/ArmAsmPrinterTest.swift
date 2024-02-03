@testable import Generator
import XCTest

final class ArmAsmPrinterTest: XCTestCase {

    func testMov() {
        let result = ArmAsmPrinter.print(instruction: .mov(dst: .x0, src: .x1))
        let expected = "    mov x0, x1\n"

        XCTAssertEqual(result, expected)
    }

    func testMovi() {
        let result = ArmAsmPrinter.print(instruction: .movi(dst: .x0, immediate: 5))
        let expected = "    mov x0, #5\n"

        XCTAssertEqual(result, expected)
    }

    func testAdd() {
        let result = ArmAsmPrinter.print(instruction: .add(dst: .x0, src1: .x1, src2: .x2))
        let expected = "    add x0, x1, x2\n"

        XCTAssertEqual(result, expected)
    }

    func testAddi() {
        let result = ArmAsmPrinter.print(instruction: .addi(dst: .x0, src: .x1, immediate: 10))
        let expected = "    add x0, x1, #10\n"

        XCTAssertEqual(result, expected)
    }

    func testSub() {
        let result = ArmAsmPrinter.print(instruction: .sub(dst: .x0, src1: .x1, src2: .x2))
        let expected = "    sub x0, x1, x2\n"

        XCTAssertEqual(result, expected)
    }

    func testSubi() {
        let result = ArmAsmPrinter.print(instruction: .subi(dst: .x0, src: .x1, immediate: 10))
        let expected = "    sub x0, x1, #10\n"

        XCTAssertEqual(result, expected)
    }

    func testMul() {
        let result = ArmAsmPrinter.print(instruction: .mul(dst: .x0, src1: .x1, src2: .x2))
        let expected = "    mul x0, x1, x2\n"

        XCTAssertEqual(result, expected)
    }

    func testMuli() {
        let result = ArmAsmPrinter.print(instruction: .muli(dst: .x0, src: .x1, immediate: 10))
        let expected = "    mul x0, x1, #10\n"

        XCTAssertEqual(result, expected)
    }

    func testDiv() {
        let result = ArmAsmPrinter.print(instruction: .div(dst: .x0, src1: .x1, src2: .x2))
        let expected = "    sdiv x0, x1, x2\n"

        XCTAssertEqual(result, expected)
    }

    func testDivi() {
        let result = ArmAsmPrinter.print(instruction: .divi(dst: .x0, src: .x1, immediate: 10))
        let expected = "    sdiv x0, x1, #10\n"

        XCTAssertEqual(result, expected)
    }

    func testPush() {
        let result = ArmAsmPrinter.print(instruction: .push(src: .x0))
        let expected = "    sub sp, sp, #16\n" + "    str x0, [sp]\n"

        XCTAssertEqual(result, expected)
    }

    func testPop() {
        let result = ArmAsmPrinter.print(instruction: .pop(dst: .x0))
        let expected = "    ldr x0, [sp]\n" + "    add sp, sp, #16\n"

        XCTAssertEqual(result, expected)
    }

    func testAddr() {
        let result = ArmAsmPrinter.print(instruction: .addr(dst: .x0, label: "hoge"))
        let expected = "    adrp x0, hoge@GOTPAGE\n"
        + "    ldr x0, [x0, hoge@GOTPAGEOFF]\n"

        XCTAssertEqual(result, expected)
    }

    func testStr() {
        let resultRegister = ArmAsmPrinter.print(instruction: .str(src: .x0, address: .register(.sp)))
        let expectedRegister = "    str x0, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .str(src: .x1, address: .distance(.sp, 8)))
        let expectedDistance = "    str x1, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testStrb() {
        let resultRegister = ArmAsmPrinter.print(instruction: .strb(src: .x0, address: .register(.sp)))
        let expectedRegister = "    strb x0, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .strb(src: .x1, address: .distance(.sp, 8)))
        let expectedDistance = "    strb x1, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testStp() {
        let resultRegister = ArmAsmPrinter.print(instruction: .stp(src1: .x29, src2: .x30, address: .register(.sp)))
        let expectedRegister = "    stp x29, x30, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .stp(src1: .x29, src2: .x30, address: .distance(.sp, 8)))
        let expectedDistance = "    stp x29, x30, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testLdr() {
        let resultRegister = ArmAsmPrinter.print(instruction: .ldr(dst: .x0, address: .register(.sp)))
        let expectedRegister = "    ldr x0, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .ldr(dst: .x1, address: .distance(.sp, 8)))
        let expectedDistance = "    ldr x1, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testLdrb() {
        let resultRegister = ArmAsmPrinter.print(instruction: .ldrb(dst: .x0, address: .register(.sp)))
        let expectedRegister = "    ldrb x0, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .ldrb(dst: .x1, address: .distance(.sp, 8)))
        let expectedDistance = "    ldrb x1, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testLdp() {
        let resultRegister = ArmAsmPrinter.print(instruction: .ldp(dst1: .x29, dst2: .x30, address: .register(.sp)))
        let expectedRegister = "    ldp x29, x30, [sp]\n"

        XCTAssertEqual(resultRegister, expectedRegister)

        let resultDistance = ArmAsmPrinter.print(instruction: .ldp(dst1: .x29, dst2: .x30, address: .distance(.sp, 8)))
        let expectedDistance = "    ldp x29, x30, [sp, #8]\n"
        XCTAssertEqual(resultDistance, expectedDistance)
    }

    func testCmp() {
        let result = ArmAsmPrinter.print(instruction: .cmp(src1: .x0, src2: .x1))
        let expected = "    cmp x0, x1\n"

        XCTAssertEqual(result, expected)
    }

    func testCmpi() {
        let result = ArmAsmPrinter.print(instruction: .cmpi(src: .x0, immediate: 10))
        let expected = "    cmp x0, #10\n"

        XCTAssertEqual(result, expected)
    }

    func testCset() {
        let resultEq = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .eq))
        let expectedEq = "    cset x0, eq\n"
        XCTAssertEqual(resultEq, expectedEq)

        let resultGe = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .ge))
        let expectedGe = "    cset x0, ge\n"
        XCTAssertEqual(resultGe, expectedGe)

        let resultGt = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .gt))
        let expectedGt = "    cset x0, gt\n"
        XCTAssertEqual(resultGt, expectedGt)

        let resultLe = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .le))
        let expectedLe = "    cset x0, le\n"
        XCTAssertEqual(resultLe, expectedLe)

        let resultLt = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .lt))
        let expectedLt = "    cset x0, lt\n"
        XCTAssertEqual(resultLt, expectedLt)

        let resultNe = ArmAsmPrinter.print(instruction: .cset(dst: .x0, flag: .ne))
        let expectedNe = "    cset x0, ne\n"
        XCTAssertEqual(resultNe, expectedNe)
    }

    func testBeq() {
        let result = ArmAsmPrinter.print(instruction: .beq(label: "hoge"))
        let expected = "    beq hoge\n"
        XCTAssertEqual(result, expected)
    }

    func testB() {
        let result = ArmAsmPrinter.print(instruction: .b(label: "hoge"))
        let expected = "    b hoge\n"
        XCTAssertEqual(result, expected)
    }

    func testBl() {
        let result = ArmAsmPrinter.print(instruction: .bl(label: "hoge"))
        let expected = "    bl hoge\n"
        XCTAssertEqual(result, expected)
    }

    func testNeg() {
        let result = ArmAsmPrinter.print(instruction: .neg(des: .x0, src: .x1))
        let expected = "    neg x0, x1\n"
        XCTAssertEqual(result, expected)
    }

    func testLsli() {
        let result = ArmAsmPrinter.print(instruction: .lsli(dst: .x0, src: .x1, immediate: 3))
        let expected = "    lsl x0, x1, #3\n"
        XCTAssertEqual(result, expected)
    }

    func testRet() {
        let result = ArmAsmPrinter.print(instruction: .ret)
        let expected = "    ret\n"
        XCTAssertEqual(result, expected)
    }

    func testLabel() {
        let result = ArmAsmPrinter.print(instruction: .label(label: "hoge"))
        let expected = "hoge:\n"

        XCTAssertEqual(result, expected)
    }

    func testP2align() {
        let result = ArmAsmPrinter.print(instruction: .p2align(factor: 2))
        let expected = ".p2align 2\n"

        XCTAssertEqual(result, expected)
    }

    func testSection() {
        let result = ArmAsmPrinter.print(instruction: .section(kinds: [.DATA,.data,.cstring,.cstring_literals,.TEXT]))
        let expected = ".section __DATA,__data,__cstring,cstring_literals,__TEXT\n"

        XCTAssertEqual(result, expected)
    }

    func testGlobl() {
        let result = ArmAsmPrinter.print(instruction: .globl(label: "hoge"))
        let expected = ".globl hoge\n"

        XCTAssertEqual(result, expected)
    }

    func testDataDecl() {
        let resultQuad = ArmAsmPrinter.print(instruction: .dataDecl(kind: .quad, value: "10"))
        let expectedQuad = "    .quad 10\n"

        XCTAssertEqual(resultQuad, expectedQuad)

        let resultByte = ArmAsmPrinter.print(instruction: .dataDecl(kind: .byte, value: "10"))
        let expectedByte = "    .byte 10\n"

        XCTAssertEqual(resultByte, expectedByte)

        let resultComm = ArmAsmPrinter.print(instruction: .dataDecl(kind: .comm, value: "a"))
        let expectedComm = "    .comm a\n"

        XCTAssertEqual(resultComm, expectedComm)

        let resultAsciz = ArmAsmPrinter.print(instruction: .dataDecl(kind: .asciz, value: "\"aiueo\""))
        let expectedAsciz = "    .asciz \"aiueo\"\n"

        XCTAssertEqual(resultAsciz, expectedAsciz)
    }
}
