import Parser

public enum GenerateError: Error {
    case invalidSyntax(index: Int)
}

public func generate(node: Node) throws -> String {
    var result = ""

    switch node.kind {
    case .number:
        result += "    mov w0, #\(node.token.value)\n"
        result += "    str w0, [sp, #-16]!\n"

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

    case .assign:
        guard let left = node.left, let right = node.right else {
            throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
        }

        // leftはアドレス, rightはrightの結果
        result += try generatePushLocalVariableAddress(node: left)
        result += try generate(node: right)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        // 代入演算
        result += "    str x0, [x1]\n"

        // 右辺を再度push（Cではa=2は2を返す）
        result += "    str x0, [sp, #-16]!\n"

        return result

    default:
        // それ以外の二項演算

        guard let left = node.left, let right = node.right else {
            throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
        }

        result += try generate(node: left)
        result += try generate(node: right)

        // 両方のノードの結果をpop
        // rightが先に取れるので w0, w1, w0の順番
        result += "    ldr w0, [sp]\n"
        result += "    add sp, sp, #16\n"
        result += "    ldr w1, [sp]\n"
        result += "    add sp, sp, #16\n"

        switch node.kind {
        case .add:
            result += "    add w0, w1, w0\n"

        case .sub:
            result += "    sub w0, w1, w0\n"

        case .mul:
            result += "    mul w0, w1, w0\n"

        case .div:
            result += "    sdiv w0, w1, w0\n"

        case .equal:
            result += "    cmp w1, w0\n"
            result += "    cset w0, eq\n"

        case .notEqual:
            result += "    cmp w1, w0\n"
            result += "    cset w0, ne\n"

        case .lessThan:
            result += "    cmp w1, w0\n"
            result += "    cset w0, lt\n"

        case .lessThanOrEqual:
            result += "    cmp w1, w0\n"
            result += "    cset w0, le\n"

        default:
            break
        }

        // 演算結果をpush
        result += "    str w0, [sp, #-16]!\n"

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
