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

    case .return:
        guard let left = node.left else {
            throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
        }

        // return結果をスタックにpush
        result += try generate(node: left)
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        // エピローグ
        // spを元の位置に戻す
        result += "    mov sp, x29\n"

        // 古いBR, 古いLRを復帰
        result += "    ldp x29, x30, [x29]\n"
        result += "    add sp, sp, #16\n"

        result += "    ret\n"

        return result

    case .while:
        guard let condition = node.left, let statement = node.right else {
            throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
        }
        let labelID = getLabelID()
        let beginLabel = "Lbegin\(labelID)"
        let endLabel = "Lend\(labelID)"

        result += ".\(beginLabel):\n"

        result += try generate(node: condition)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        result += "    cmp x0, #0\n"
        result += "    beq .\(endLabel)\n"

        result += try generate(node: statement)

        result += "    b .\(beginLabel)\n"

        result += ".\(endLabel):\n"

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

private var labelCount = 0
func getLabelID() -> String {
    let id = labelCount
    labelCount += 1

    return id.description
}

private var variableAddressOffset: [String: Int] = [:]

/// nameの変数のアドレスをスタックにpushするコードを生成する
private func generatePushLocalVariableAddress(node: Node) throws -> String {
    guard node.kind == .localVariable else {
        throw GenerateError.invalidSyntax(index: node.token.sourceIndex)
    }

    var result = ""

    let offset: Int = {
        if let offset = variableAddressOffset[node.token.value] {
            return offset
        } else {
            let offset = (variableAddressOffset.count + 1) * 8
            variableAddressOffset[node.token.value] = offset

            return offset
        }
    }()
    result += "    sub x0, x29, #\(offset)\n"
    result += "    str x0, [sp, #-16]!\n"

    return result
}
