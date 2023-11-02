import Parser

public func generate(node: Node) -> String {
    var result = ""

    if node.kind == .number {
        result += "    mov w0, #\(node.token.value)\n"
        result += "    str w0, [sp, #-16]!\n"

        return result
    }

    if let left = node.left {
        result += generate(node: left)
    }

    if let right = node.right {
        result += generate(node: right)
    }

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

    default:
        break
    }

    // 演算結果をpush
    result += "    str w0, [sp, #-16]!\n"

    return result
}
