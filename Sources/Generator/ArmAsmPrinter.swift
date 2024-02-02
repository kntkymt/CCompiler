private extension AsmRepresent.Instruction.Address {
    var description: String {
        switch self {
        case .register(let register): register.rawValue
        case .distance(let register, let diff): "\(register.rawValue), #\(diff)"
        }
    }
}

public enum ArmAsmPrinter {
    public static func print(instructions: [AsmRepresent.Instruction]) -> String {
        instructions.map { print(instruction: $0) }.reduce("") { $0 + $1 }
    }

    static func print(instruction: AsmRepresent.Instruction) -> String {
        func inst(opecode: String, a: AsmRepresent.Register, b: AsmRepresent.Register) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue)\n"
        }

        func inst(opecode: String, a: AsmRepresent.Register, immediate: String) -> String {
            "    \(opecode) \(a.rawValue), #\(immediate)\n"
        }

        func inst(opecode: String, a: AsmRepresent.Register, b: AsmRepresent.Register, c: AsmRepresent.Register) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), \(c.rawValue)\n"
        }

        func inst(opecode: String, a: AsmRepresent.Register, b: AsmRepresent.Register, immediate: String) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), #\(immediate)\n"
        }

        func inst(opecode: String, a: AsmRepresent.Register, address: AsmRepresent.Instruction.Address) -> String {
            "    \(opecode) \(a.rawValue), [\(address.description)]\n"
        }

        func inst(opecode: String, a: AsmRepresent.Register, b: AsmRepresent.Register, address: AsmRepresent.Instruction.Address) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), [\(address.description)]\n"
        }

        func inst(opecode: String, label: String) -> String {
            "    \(opecode) \(label)\n"
        }

        return switch instruction {
        case .mov(let dst, let src): 
            inst(opecode: "mov", a: dst, b: src)
        case .movi(let dst, let immediate): 
            inst(opecode: "mov", a: dst, immediate: immediate.description)
        case .add(let dst, let src1, let src2): 
            inst(opecode: "add", a: dst, b: src1, c: src2)
        case .addi(let dst, let src, let immediate):
            inst(opecode: "add", a: dst, b: src, immediate: immediate.description)
        case .sub(let dst, let src1, let src2):
            inst(opecode: "sub", a: dst, b: src1, c: src2)
        case .subi(let dst, let src, let immediate):
            inst(opecode: "sub", a: dst, b: src, immediate: immediate.description)
        case .mul(let dst, let src1, let src2):
            inst(opecode: "mul", a: dst, b: src1, c: src2)
        case .muli(let dst, let src, let immediate):
            inst(opecode: "mul", a: dst, b: src, immediate: immediate.description)
        case .div(let dst, let src1, let src2):
            inst(opecode: "sdiv", a: dst, b: src1, c: src2)
        case .divi(let dst, let src, let immediate):
            inst(opecode: "sdiv", a: dst, b: src, immediate: immediate.description)
        case .push(let src):
            "    str \(src.rawValue), [sp, #-16]!\n"
        case .pop(let dst):
            inst(opecode: "ldr", a: dst, address: .register(.sp))
            + inst(opecode: "add", a: .sp, b: .sp, immediate: "16")
        case .addr(let dst, let label):
            "    adrp \(dst.rawValue), \(label)@GOTPAGE\n"
            + "    ldr \(dst.rawValue), [\(dst.rawValue), \(label)@GOTPAGEOFF]\n"
        case .str(let src, let address):
            inst(opecode: "str", a: src, address: address)
        case .strb(let src, let address):
            inst(opecode: "strb", a: src, address: address)
        case .stp(let src1, let src2, let address):
            inst(opecode: "stp", a: src1, b: src2, address: address)
        case .ldr(let dst, let address):
            inst(opecode: "ldr", a: dst, address: address)
        case .ldrb(let dst, let address):
            inst(opecode: "ldrb", a: dst, address: address)
        case .ldp(let dst1, let dst2, let address):
            inst(opecode: "ldp", a: dst1, b: dst2, address: address)
        case .cmp(let src1, let src2):
            inst(opecode: "cmp", a: src1, b: src2)
        case .cmpi(let src, let immediate):
            inst(opecode: "cmp", a: src, immediate: immediate.description)
        case .cset(let dst, let flag):
            "    cset \(dst.rawValue), \(flag.rawValue)\n"
        case .beq(let label):
            inst(opecode: "beq", label: label == "main" ? "_main" : label)
        case .b(let label):
            inst(opecode: "b", label: label == "main" ? "_main" : label)
        case .bl(let label):
            inst(opecode: "bl", label: label == "main" ? "_main" : label)
        case .neg(let dst, let src):
            inst(opecode: "neg", a: dst, b: src)
        case .lsli(let dst, let src, let immediate):
            inst(opecode: "lsl", a: dst, b: src, immediate: immediate.description)
        case .ret:
            "    ret\n"
        case .label(let label):
            "\(label == "main" ? "_main" : label):\n"
        case .p2align(let factor):
            ".p2align \(factor)\n"
        case .section(let kinds):
            ".section \(kinds.map { $0.rawValue }.joined(separator: ","))\n"
        case .globl(let label):
            ".globl \(label == "main" ? "_main" : label)\n"
        case .dataDecl(let kind, let value):
            "    .\(kind.rawValue) \(value)\n"
        }
    }
}
