import Parser

public enum GenerateError: Error {
    case invalidSyntax(index: Int)
    case noSuchVariable(varibaleName: String, index: Int)
}

extension NodeProtocol {
    func casted<T: NodeProtocol>(_ type: T.Type) throws -> T {
        guard let casted = self as? T else { throw GenerateError.invalidSyntax(index: self.sourceTokens[0].sourceIndex) }

        return casted
    }
}

public final class Generator {

    // MARK: - Property

    private var labelCount = 0
    func getLabelID() -> String {
        let id = labelCount
        labelCount += 1

        return id.description
    }

    struct VariableInfo {
        var type: any TypeNodeProtocol
        var addressOffset: Int
    }

    private var globalVariables: [String: any TypeNodeProtocol] = [:]
    private var variables: [String: VariableInfo] = [:]
    private var functionLabels: Set<String> = Set()

    public init() {
    }

    // MARK: - Public

    public func generate(sourceFileNode: SourceFileNode) throws -> String {

        var variableDeclResult = ""
        for variableDecl in sourceFileNode.globalVariables {
            variableDeclResult += try generateGlobalVariable(node: variableDecl)
        }

        var functionDeclResult = ""
        for functionDecl in sourceFileNode.functions {
            functionDeclResult += try generate(node: functionDecl)
        }

        let functionMeta = ".globl \(functionLabels.joined(separator: ", "))\n"

        return variableDeclResult + functionMeta + functionDeclResult
    }

    func generateGlobalVariable(node: VariableDeclNode) throws -> String {
        var result = ""

        result += "\(node.identifierName):\n"
        result += "    .zero \(node.type.memorySize)\n"

        globalVariables[node.identifierName] = node.type

        return result
    }

    func generate(node: any NodeProtocol) throws -> String {
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

            // 配列の場合は先頭アドレスのまま返す
            // 配列以外の場合はアドレスの中身を返す
            if variables[casted.identifierName]?.type.kind != .arrayType {
                // アドレスをpop
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // アドレスを値に変換してpush
                result += "    ldr x0, [x0]\n"
                result += "    str x0, [sp, #-16]!\n"
            }

            return result

        case .functionCallExpr:
            let casted = try node.casted(FunctionCallExpressionNode.self)

            // 引数を評価してスタックに積む
            for argument in casted.arguments {
                result += try generate(node: argument)
            }

            // 引数を関数に引き渡すためレジスタに入れる
            // 結果はスタックに積まれているので番号は逆から
            // 例: call(a, b) -> x0: a, x1: b
            for registorIndex in (0..<casted.arguments.count).reversed() {
                result += "    ldr x\(registorIndex), [sp]\n"
                result += "    add sp, sp, #16\n"
            }

            let functionLabel = casted.functionName == "main" ? "_main" : casted.functionName
            result += "    bl \(functionLabel)\n"

            // 帰り値をpush
            result += "    str x0, [sp, #-16]!\n"

            return result

        case .functionDecl:
            let casted = try node.casted(FunctionDeclNode.self)

            // 関数定義ごとに作り直す
            variables = [:]

            let functionLabel = casted.functionName == "main" ? "_main" : casted.functionName
            functionLabels.insert(functionLabel)
            result += "\(functionLabel):\n"

            // プロローグ
            var prologue = ""
            // push 古いBR, 呼び出し元LR
            prologue += "    stp x29, x30, [sp, #-16]!\n"
            // 今のスタックのトップをBRに（新しい関数フレームを宣言）
            prologue += "    mov x29, sp\n"

            var parameterDecl = ""
            // 引数をローカル変数として保存し直す
            for (index, parameter) in casted.parameterNodes.enumerated() {
                let offset = (variables.count + 1) * 8
                variables[parameter.identifierName] = VariableInfo(type: parameter.type, addressOffset: offset)

                parameterDecl += "    str x\(index), [x29, #-\(offset)]\n"
            }

            let body = try generate(node: casted.block)

            // 確保するスタックの量はbodyを見てからじゃないとわからない
            result += prologue

            if !variables.isEmpty {
                // FIXME: スタックのサイズは16の倍数...のはずだが32じゃないとダメっぽい？
                let variableSize = variables.reduce(0) { $0 + $1.value.type.memorySize }
                result += "    sub sp, sp, #\(variableSize.isMultiple(of: 64) ? variableSize : (1 + variableSize / 128) * 128)\n"
            }

            result += parameterDecl
            result += body

            return result

        case .variableDecl:
            let casted = try node.casted(VariableDeclNode.self)

            let offset = variables.reduce(0) { $0 + $1.value.type.memorySize } + casted.type.memorySize
            variables[casted.identifierName] = VariableInfo(type: casted.type, addressOffset: offset)

            return ""

        case .subscriptCallExpr:
            let casted = try node.casted(SubscriptCallExpressionNode.self)

            result += try generatePushLocalArrayElementAddress(node: casted)

            // 結果のアドレスの値をロードしてスタックに積む
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
            result += "    ldr x0, [x0]\n"
            result += "    str x0, [sp, #-16]!\n"

            return  result

        case .arrayType:
            fatalError()

        case .pointerType:
            // 今は型の一致を見ていない
            fatalError()

        case .type:
            fatalError()

        case .blockStatement:
            let casted = try node.casted(BlockStatementNode.self)

            for statement in casted.statements {
                result += try generate(node: statement)

                // 次のstmtに行く前に今のstmtの最終結果を消す
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

        case .prefixOperatorExpr:
            let casted = try node.casted(PrefixOperatorExpressionNode.self)

            switch casted.operatorKind {
            case .reference:
                // *のあとはどんな値でも良い
                result += try generate(node: casted.right)

                // 値をロードしてpush
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // 値をアドレスとして読み、アドレスが指す値をロード
                result += "    ldr x0, [x0]\n"
                result += "    str x0, [sp, #-16]!\n"

            case .address:
                // &のあとは変数しか入らない（はず？）
                if let right = casted.right as? IdentifierNode {
                    result += try generatePushLocalVariableAddress(node: right)
                } else {
                    throw GenerateError.invalidSyntax(index: node.sourceTokens[0].sourceIndex)
                }
            }

            return result

        case .infixOperatorExpr:
            let casted = try node.casted(InfixOperatorExpressionNode.self)

            if casted.operator is AssignNode {
                // 左辺は変数, `*値`, subscriptCall
                if casted.left is IdentifierNode {
                    result += try generatePushLocalVariableAddress(node: casted.left.casted(IdentifierNode.self))
                } else if let pointer = casted.left as? PrefixOperatorExpressionNode, pointer.operatorKind == .reference {
                    result += try generate(node: pointer.right)
                } else if let subscriptCall = casted.left as? SubscriptCallExpressionNode {
                    result += try generatePushLocalArrayElementAddress(node: subscriptCall)
                } else {
                    throw GenerateError.invalidSyntax(index: casted.left.sourceTokens[0].sourceIndex)
                }

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

                if binaryOperator.operatorKind == .add || binaryOperator.operatorKind == .sub {
                    // addまたはsubの時、一方が変数でポインタ型または配列だったら、他方を8倍する
                    // 8は8バイト（ポインタの指すサイズ、今は全部8バイトなので）
                    if let identifier = casted.left as? IdentifierNode,
                       variables[identifier.identifierName]?.type is PointerTypeNode || variables[identifier.identifierName]?.type is ArrayTypeNode {
                        result += "    lsl x0, x0, #3\n"
                    } else if let identifier = casted.right as? IdentifierNode, variables[identifier.identifierName]?.type is PointerTypeNode || variables[identifier.identifierName]?.type is ArrayTypeNode {
                        result += "    lsl x1, x1, #3\n"
                    }
                }

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

        case .binaryOperator:
            fatalError()

        case .assign:
            fatalError()

        case .sourceFile:
            fatalError()
        }
    }

    // MARK: - Private

    /// nameの変数のアドレスをスタックにpushするコードを生成する
    private func generatePushLocalVariableAddress(node: IdentifierNode) throws -> String {
        var result = ""

        guard let offset = variables[node.identifierName]?.addressOffset else {
            throw GenerateError.noSuchVariable(varibaleName: node.identifierName, index: node.token.sourceIndex)
        }

        result += "    sub x0, x29, #\(offset)\n"
        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    private func generatePushLocalArrayElementAddress(node: SubscriptCallExpressionNode) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushLocalVariableAddress(node: node.identifierNode)
        result += try generate(node: node.argument)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        // subscriptの方は8倍
        result += "    lsl x0, x0, 3\n"

        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        // identifierがポインタだった場合はアドレスが指す値にする
        if variables[node.identifierNode.identifierName]?.type.kind == .pointerType {
            result += "    ldr x1, [x1]\n"

        }

        // それらを足す
        result += "    add x0, x1, x0\n"

        result += "    str x0, [sp, #-16]!\n"

        return result
    }
}
