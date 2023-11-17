import Parser

public enum GenerateError: Error {
    case invalidSyntax(index: Int)
}

extension NodeProtocol {
    func casted<T: NodeProtocol>(_ type: T.Type) throws -> T {
        guard let casted = self as? T else { throw GenerateError.invalidSyntax(index: self.sourceTokens[0].sourceIndex) }

        return casted
    }
}

public func generate(node: any NodeProtocol) throws -> String {
    var result = ""

    switch node.kind {
    case .integerLiteral:
        let casted = try node.casted(IntegerLiteralNode.self)
        result += "    mov x0, #\(casted.literal)\n"
        result += "    str x0, [sp, #-16]!\n"

        return result

    case .identifier:
        let casted = try node.casted(IdentifierNode.self)
        // アドレスをpush
        result += try generatePushLocalVariableAddress(node: casted)

        // アドレスをpop
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        // アドレスを値に変換してpush
        result += "    ldr x0, [x0]\n"
        result += "    str x0, [sp, #-16]!\n"

        return result

    case .blockStatement:
        let casted = try node.casted(BlockStatementNode.self)

        for statement in casted.statements {
            result += try generate(node: statement)

            // いらない結果をpop
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
        }

        return result

    case .returnStatement:
        let casted = try node.casted(ReturnStatementNode.self)

        // return結果をスタックにpush
        result += try generate(node: casted.expression)
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

    case .whileStatement:
        let casted = try node.casted(WhileStatementNode.self)
        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        result += "\(beginLabel):\n"

        result += try generate(node: casted.condition)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        result += "    cmp x0, #0\n"
        result += "    beq \(endLabel)\n"

        result += try generate(node: casted.body)

        result += "    b \(beginLabel)\n"

        result += "\(endLabel):\n"

        return result

    case .ifStatement:
        let casted = try node.casted(IfStatementNode.self)
        let labelID = getLabelID()
        let endLabel = ".Lend\(labelID)"

        result += try generate(node: casted.condition)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        result += "    cmp x0, #0\n"

        if let falseBody = casted.falseBody {
            let elseLabel = ".Lelse\(labelID)"

            result += "    beq \(elseLabel)\n"
            result += try generate(node: casted.trueBody)
            result += "    b \(endLabel)\n"

            result += "\(elseLabel):\n"
            result += try generate(node: falseBody)

        } else {
            result += "    beq \(endLabel)\n"

            result += try generate(node: casted.trueBody)
        }

        result += "\(endLabel):\n"

        return result

    case .forStatement:
        let casted = try node.casted(ForStatementNode.self)

        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        if let preExpr = casted.pre {
            result += try generate(node: preExpr)
        }

        result += "\(beginLabel):\n"

        if let condition = casted.condition {
            result += try generate(node: condition)

            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
        } else {
            // 条件がない場合はtrue
            result += "    mov x0, #1\n"
        }

        result += "    cmp x0, #0\n"
        result += "    beq \(endLabel)\n"

        result += try generate(node: casted.body)

        if let postExpr = casted.post {
            result += try generate(node: postExpr)
        }

        result += "    b \(beginLabel)\n"

        result += "\(endLabel):\n"

        return result

    case .infixOperatorExpr:
        let casted = try node.casted(InfixOperatorExpressionNode.self)

        if casted.operator is AssignNode {
            result += try generatePushLocalVariableAddress(node: casted.left.casted(IdentifierNode.self))
            result += try generate(node: casted.right)

            // 両方のノードの結果をpop
            // rightが先に取れるので x0, x1, x0の順番
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
            result += "    ldr x1, [sp]\n"
            result += "    add sp, sp, #16\n"

            // assign
            result += "    str x0, [x1]\n"

            result += "    str x0, [sp, #-16]!\n"


        } else if let binaryOperator = casted.operator as? BinaryOperatorNode {
            result += try generate(node: casted.left)
            result += try generate(node: casted.right)

            // 両方のノードの結果をpop
            // rightが先に取れるので x0, x1, x0の順番
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
            result += "    ldr x1, [sp]\n"
            result += "    add sp, sp, #16\n"

            switch binaryOperator.operatorKind {
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

            case .greaterThan:
                result += "    cmp x1, x0\n"
                result += "    cset x0, gt\n"

            case .greaterThanOrEqual:
                result += "    cmp x1, x0\n"
                result += "    cset x0, ge\n"
            }

            result += "    str x0, [sp, #-16]!\n"

        } else {
            throw GenerateError.invalidSyntax(index: node.sourceTokens[0].sourceIndex)
        }

        return result

    default:
        throw GenerateError.invalidSyntax(index: node.sourceTokens[0].sourceIndex)
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
private func generatePushLocalVariableAddress(node: IdentifierNode) throws -> String {
    var result = ""

    let offset: Int = {
        if let offset = variableAddressOffset[node.identifierName] {
            return offset
        } else {
            let offset = (variableAddressOffset.count + 1) * 8
            variableAddressOffset[node.identifierName] = offset

            return offset
        }
    }()
    result += "    sub x0, x29, #\(offset)\n"
    result += "    str x0, [sp, #-16]!\n"

    return result
}
