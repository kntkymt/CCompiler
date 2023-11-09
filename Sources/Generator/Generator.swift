import Parser

public enum GenerateError: Error {
    case invalidSyntax(index: Int)
}

public func generate(node: Node) throws -> String {
    var result = ""

    switch node.kind {
    case .number:
        result += "    mov x0, #\(node.token.value)\n"
        result += "    str x0, [sp, #-16]!\n"

        return result

    case .localVariable:
        // アドレスをpush
        result += try generatePushLocalVariableAddress(node: node)

        // アドレスをpop
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        // アドレスを値に変換してpush
        result += "    ldr x0, [x0]\n"
        result += "    str x0, [sp, #-16]!\n"

        return result

    default:
        // それ以外の演算

        guard let left = node.left, let right = node.right else {
            throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
        }

        if node.kind == .assign {
            result += try generatePushLocalVariableAddress(node: left)
        } else {
            result += try generate(node: left)
        }
        result += try generate(node: right)

        // 両方のノードの結果をpop
        // rightが先に取れるので x0, x1, x0の順番
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        switch node.kind {
        case .add:
            result += "    add x0, x1, x0\n"

        case .sub:
            result += "    sub x0, x1, x0\n"

        case .mul:
            result += "    mul x0, x1, x0\n"

        case .div:
            result += "    sdiv x0, x1, x0\n"

        case .equal:
            result += "    cmp x1, x0\n"
            result += "    cset x0, eq\n"

        case .notEqual:
            result += "    cmp x1, x0\n"
            result += "    cset x0, ne\n"

        case .lessThan:
            result += "    cmp x1, x0\n"
            result += "    cset x0, lt\n"

        case .lessThanOrEqual:
            result += "    cmp x1, x0\n"
            result += "    cset x0, le\n"

        case .assign:
            result += "    str x0, [x1]\n"

        default:
            break
        }

        // 演算結果をpush
        result += "    str x0, [sp, #-16]!\n"

        return result
    }
}

/// nameの変数のアドレスをスタックにpushするコードを生成する
private func generatePushLocalVariableAddress(node: Node) throws -> String {
    guard node.kind == .localVariable, let variableName = node.token.value.first else {
        throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
    }

    var result = ""

    // BRから a, b, c, d...と固定で変数が確保されている想定
    let offset = (variableName.asciiValue! - Character("a").asciiValue! + 1) * 8

    result += "    sub x0, x29, #\(offset)\n"
    result += "    str x0, [sp, #-16]!\n"

    return result
}
