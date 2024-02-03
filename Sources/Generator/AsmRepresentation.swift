
public enum AsmRepresent {

    public enum Instruction {
        case mov(dst: Register, src: Register)
        case movi(dst: Register, immediate: Int64)

        case add(dst: Register, src1: Register, src2: Register)
        case addi(dst: Register, src: Register, immediate: Int64)
        case sub(dst: Register, src1: Register, src2: Register)
        case subi(dst: Register, src: Register, immediate: Int64)
        case mul(dst: Register, src1: Register, src2: Register)
        case muli(dst: Register, src: Register, immediate: Int64)
        case div(dst: Register, src1: Register, src2: Register)
        case divi(dst: Register, src: Register, immediate: Int64)

        case push(src: Register)
        case pop(dst: Register)

        /// dstにlabelのアドレスを入れる
        case addr(dst: Register, label: String)

        case str(src: Register, address: Address)
        case strb(src: Register, address: Address)
        case stp(src1: Register, src2: Register, address: Address)
        case ldr(dst: Register, address: Address)
        case ldrb(dst: Register, address: Address)
        case ldp(dst1: Register, dst2: Register, address: Address)

        case cmp(src1: Register, src2: Register)
        case cmpi(src: Register, immediate: Int64)

        case cset(dst: Register, flag: CsetFlag)

        case beq(label: String)
        case b(label: String)
        case bl(label: String)

        case neg(des: Register, src: Register)

        case lsli(dst: Register, src: Register, immediate: UInt64)

        case ret

        // 実際には命令ではない、別のデータ構造で表すべき？
        case label(label: String)
        case p2align(factor: UInt64)
        case section(kinds: [SectionKind])
        case globl(label: String)
        case dataDecl(kind: DataKind, value: String)

        public enum Address {
            case register(_ register: Register)
            case distance(_ register: Register, _ diff: Int64)
        }

        public enum CsetFlag: String {
            case eq
            case ne
            case lt
            case le
            case gt
            case ge
        }

        public enum SectionKind: String {
            case DATA = "__DATA"
            case data = "__data"
            case TEXT = "__TEXT"
            case cstring = "__cstring"
            case cstring_literals = "cstring_literals"
        }

        public enum DataKind: String {
            case byte
            case quad
            case asciz
            case comm
        }
    }

    public enum Register: String {
        case x0
        case x1
        case x2
        case x3
        case x4

        case w0
        case w1
        case w2
        case w3
        case w4

        case x29
        case x30

        case sp

        static func x(_ index: Int) -> Register {
            switch index {
            case 0: .x0
            case 1: .x1
            case 2: .x2
            case 3: .x3
            case 4: .x4
            default: fatalError()
            }
        }

        static func w(_ index: Int) -> Register {
            switch index {
            case 0: .w0
            case 1: .w1
            case 2: .w2
            case 3: .w3
            case 4: .w4
            default: fatalError()
            }
        }
    }

}
