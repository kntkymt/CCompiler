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
        /// opecode a, b
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ b: AsmRepresent.Register) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue)\n"
        }

        /// opecode a, #immediate
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ immediate: Int64) -> String {
            "    \(opecode) \(a.rawValue), #\(immediate)\n"
        }

        /// opecode a, b, c
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ b: AsmRepresent.Register, _ c: AsmRepresent.Register) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), \(c.rawValue)\n"
        }

        /// opecode a, b, #immediate
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ b: AsmRepresent.Register, _ immediate: Int64) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), #\(immediate)\n"
        }

        /// opecode a, [address]
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ address: AsmRepresent.Instruction.Address) -> String {
            "    \(opecode) \(a.rawValue), [\(address.description)]\n"
        }

        /// opecode a, b, [address]
        func inst(_ opecode: String, _ a: AsmRepresent.Register, _ b: AsmRepresent.Register, _ address: AsmRepresent.Instruction.Address) -> String {
            "    \(opecode) \(a.rawValue), \(b.rawValue), [\(address.description)]\n"
        }

        /// opecode label
        func inst(_ opecode: String, _ label: String) -> String {
            "    \(opecode) \(fixLabel(label))\n"
        }

        /// AppleClangではmainが_main じゃないとダメなので対応
        func fixLabel(_ label: String) -> String {
            label == "main" ? "_main" : label
        }

        return switch instruction {
        case .mov(let dst, let src): 
            inst("mov", dst, src)
        case .movi(let dst, let immediate): 
            inst("mov", dst, immediate)
        case .add(let dst, let src1, let src2): 
            inst("add", dst, src1, src2)
        case .addi(let dst, let src, let immediate):
            inst("add", dst, src, immediate)
        case .sub(let dst, let src1, let src2):
            inst("sub", dst, src1, src2)
        case .subi(let dst, let src, let immediate):
            inst("sub", dst, src, immediate)
        case .mul(let dst, let src1, let src2):
            inst("mul", dst, src1, src2)
        case .muli(let dst, let src, let immediate):
            inst("mul", dst, src, immediate)
        case .div(let dst, let src1, let src2):
            inst("sdiv", dst, src1, src2)
        case .divi(let dst, let src, let immediate):
            inst("sdiv", dst, src, immediate)
        case .push(let src):
            inst("sub", .sp, .sp, 16)
            + inst("str", src, .register(.sp))
        case .pop(let dst):
            inst("ldr", dst, .register(.sp))
            + inst("add", .sp, .sp, 16)
        case .addr(let dst, let label):
            "    adrp \(dst.rawValue), \(label)@GOTPAGE\n"
            + "    ldr \(dst.rawValue), [\(dst.rawValue), \(label)@GOTPAGEOFF]\n"
        case .str(let src, let address):
            inst("str", src, address)
        case .strb(let src, let address):
            inst("strb", src, address)
        case .stp(let src1, let src2, let address):
            inst("stp", src1, src2, address)
        case .ldr(let dst, let address):
            inst("ldr", dst, address)
        case .ldrb(let dst, let address):
            inst("ldrb", dst, address)
        case .ldp(let dst1, let dst2, let address):
            inst("ldp", dst1, dst2, address)
        case .cmp(let src1, let src2):
            inst("cmp", src1, src2)
        case .cmpi(let src, let immediate):
            inst("cmp", src, immediate)
        case .cset(let dst, let flag):
            "    cset \(dst.rawValue), \(flag.rawValue)\n"
        case .beq(let label):
            inst("beq", label)
        case .b(let label):
            inst("b", label)
        case .bl(let label):
            inst("bl", label)
        case .neg(let dst, let src):
            inst("neg", dst, src)
        case .lsli(let dst, let src, let immediate):
            inst("lsl", dst, src, Int64(immediate))
        case .ret:
            "    ret\n"
        case .label(let label):
            "\(fixLabel(label)):\n"
        case .p2align(let factor):
            ".p2align \(factor)\n"
        case .section(let kinds):
            ".section \(kinds.map { $0.rawValue }.joined(separator: ","))\n"
        case .globl(let label):
            ".globl \(fixLabel(label))\n"
        case .dataDecl(let kind, let value):
            "    .\(kind.rawValue) \(value)\n"
        }
    }
}
