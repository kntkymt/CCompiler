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
    private var stringLiteralLabels: [String: String] = [:]
    private var functionLabels: Set<String> = Set()

    public init() {
    }

    // MARK: - Public

    public func generate(sourceFileNode: SourceFileNode) throws -> String {

        var dataSection = ""
        var functionDeclResult = ""
        for statement in sourceFileNode.statements {
            switch statement.item.kind {
            case .variableDecl:
                if dataSection.isEmpty {
                    dataSection += ".section    __DATA,__data\n"
                }

                let casted = try statement.item.casted(VariableDeclNode.self)
                dataSection += try generateGlobalVariableDecl(node: casted)

            case .functionDecl:
                let casted = try statement.item.casted(FunctionDeclNode.self)
                functionDeclResult += ".p2align 2\n"
                functionDeclResult += try generate(node: casted)

            default:
                throw GenerateError.invalidSyntax(index: statement.sourceTokens.first!.sourceIndex)
            }
        }

        let functionMeta = ".globl \(functionLabels.joined(separator: ", "))\n"

        if !stringLiteralLabels.isEmpty {
            dataSection += ".section __TEXT,__cstring,cstring_literals\n"
            for (literal, label) in stringLiteralLabels {
                dataSection += "\(label):\n"
                dataSection += "    .asciz \"\(literal)\"\n"
            }
        }

        return functionMeta + functionDeclResult + dataSection
    }

    func generateGlobalVariableDecl(node: VariableDeclNode) throws -> String {
        globalVariables[node.identifierName] = node.type

        var result = ""

        if let initializerExpr = node.initializerExpr {

            result += ".globl \(node.identifierName)\n"
            if node.type.memorySize != 1 {
                result += ".p2align 3, 0x0\n"
            }
            result += "\(node.identifierName):\n"

            switch initializerExpr.kind {
            case .integerLiteral:
                let sizeKind = node.type.memorySize == 1 ? "byte" : "quad"
                let value = try initializerExpr.casted(IntegerLiteralNode.self).literal
                result += "    .\(sizeKind) \(value)\n"

            case .stringLiteral:
                let value = try initializerExpr.casted(StringLiteralNode.self).value
                result += "    .asciz \"\(value)\"\n"

            case .prefixOperatorExpr:
                let prefixOperatorExpr = try initializerExpr.casted(PrefixOperatorExpressionNode.self)
                if prefixOperatorExpr.operatorKind == .address {
                    let value = try prefixOperatorExpr.expression.casted(IdentifierNode.self).identifierName
                    result += "    .quad \(value)\n"
                } else {
                    throw GenerateError.invalidSyntax(index: initializerExpr.sourceTokens.first!.sourceIndex)
                }

            case .infixOperatorExpr:
                let infixOperator = try initializerExpr.casted(InfixOperatorExpressionNode.self)

                func generateAddressValue(referenceNode: any NodeProtocol, integerLiteralNode: any NodeProtocol) -> String? {
                    if let prefix = referenceNode as? PrefixOperatorExpressionNode,
                       prefix.operatorKind == .address,
                       let identifier = prefix.expression as? IdentifierNode,
                       let binaryOperator = infixOperator.operator as? BinaryOperatorNode,
                       (binaryOperator.operatorKind == .add || binaryOperator.operatorKind == .sub),
                       let integerLiteral = integerLiteralNode as? IntegerLiteralNode {
                        return "    .quad \(identifier.identifierName) \(binaryOperator.token.value) \(integerLiteral.literal)\n"
                    } else {
                        return nil
                    }
                }

                // 左右一方が「&変数」, 他方が「IntergerLiteral」のはず
                if let leftIsReference = generateAddressValue(referenceNode: infixOperator.left, integerLiteralNode: infixOperator.right) {
                    result += leftIsReference
                } else if let rightIsReference = generateAddressValue(referenceNode: infixOperator.right, integerLiteralNode: infixOperator.left) {
                    result += rightIsReference
                } else {
                    throw GenerateError.invalidSyntax(index: initializerExpr.sourceTokens.first!.sourceIndex)
                }

            default:
                throw GenerateError.invalidSyntax(index: initializerExpr.sourceTokens.first!.sourceIndex)
            }
        } else {
            // Apple Clangでは初期化がない場合は.commじゃないとダメっぽい？
            let alignment = isElementOrReferenceTypeMemorySizeOf(1, identifierName: node.identifierName) ? 0 : 3
            result += ".comm \(node.identifierName),\(node.type.memorySize),\(alignment)\n"
        }

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

        case .stringLiteral:
            // stringLiteral自体はグローバル領域に定義し
            // 式自体は先頭のポインタを表す
            let casted = try node.casted(StringLiteralNode.self)
            let label: String
            if let stringLabel = stringLiteralLabels[casted.value] {
                label = stringLabel
            } else {
                let stringLabel = "strings\(stringLiteralLabels.count)"
                stringLiteralLabels[casted.value] = stringLabel
                label = stringLabel
            }

            result += "    adrp x0, \(label)@GOTPAGE\n"
            result += "    ldr x0, [x0, \(label)@GOTPAGEOFF]\n"

            result += "    str x0, [sp, #-16]!\n"

            return result

        case .identifier:
            let casted = try node.casted(IdentifierNode.self)

            // アドレスをpush
            result += try generatePushVariableAddress(node: casted)

            // 配列の場合は先頭アドレスのまま返す
            // 配列以外の場合はアドレスの中身を返す
            if let variableType = getVariableType(name: casted.identifierName), variableType.kind != .arrayType {
                // アドレスをpop
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // アドレスを値に変換してpush
                if variableType.memorySize == 1 {
                    result += "    ldrb w0, [x0]\n"
                } else {
                    result += "    ldr x0, [x0]\n"
                }
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

        case .exprListItem:
            let casted = try node.casted(ExpressionListItemNode.self)
            return try generate(node: casted.expression)

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

        case .functionParameter:
            // functionDecl側で処理
            fatalError()

        case .variableDecl:
            let casted = try node.casted(VariableDeclNode.self)

            let offset = variables.reduce(0) { $0 + $1.value.type.memorySize } + casted.type.memorySize
            variables[casted.identifierName] = VariableInfo(type: casted.type, addressOffset: offset)

            if let initializerExpr = casted.initializerExpr {
                switch initializerExpr.kind {
                case .arrayExpr:
                    // = { }
                    let arrayExpr = try initializerExpr.casted(ArrayExpressionNode.self)

                    for (arrayIndex, element) in arrayExpr.exprListNodes.enumerated() {
                        result += try generatePushArrayElementAddress(identifierName: casted.identifierName, index: arrayIndex, sourceIndex: casted.identifierToken.sourceIndex)
                        result += try generate(node: element)

                        result += "    ldr x0, [sp]\n"
                        result += "    add sp, sp, #16\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifierName) {
                            result += "    strb w0, [x1]\n"
                        } else {
                            result += "    str x0, [x1]\n"
                        }
                    }

                    // { ... }の要素が足りなかったら0埋めする
                    let arrayType = try casted.type.casted(ArrayTypeNode.self)
                    if arrayExpr.exprListNodes.count < arrayType.arraySize {
                        for arrayIndex in arrayExpr.exprListNodes.count..<arrayType.arraySize {
                            result += try generatePushArrayElementAddress(identifierName: casted.identifierName, index: arrayIndex, sourceIndex: casted.identifierToken.sourceIndex)

                            result += "    mov x0, #0\n"
                            result += "    ldr x1, [sp]\n"
                            result += "    add sp, sp, #16\n"

                            if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifierName) {
                                result += "    strb w0, [x1]\n"
                            } else {
                                result += "    str x0, [x1]\n"
                            }
                        }
                    }

                    return result

                case .stringLiteral:
                    // = ""
                    if casted.type is PointerTypeNode { fallthrough }

                    let stringLiteralNode = try initializerExpr.casted(StringLiteralNode.self)
                    for (arrayIndex, element) in stringLiteralNode.value.enumerated() {
                        result += try generatePushArrayElementAddress(identifierName: casted.identifierName, index: arrayIndex, sourceIndex: casted.identifierToken.sourceIndex)

                        result += "    mov x0, #\(element.asciiValue ?? 0)\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        result += "    strb w0, [x1]\n"
                    }

                    // ""の要素が足りなかったら0埋めする
                    let arrayType = try casted.type.casted(ArrayTypeNode.self)
                    if stringLiteralNode.value.count < arrayType.arraySize {
                        for arrayIndex in stringLiteralNode.value.count..<arrayType.arraySize {
                            result += try generatePushArrayElementAddress(identifierName: casted.identifierName, index: arrayIndex, sourceIndex: casted.identifierToken.sourceIndex)

                            result += "    mov x0, #0\n"
                            result += "    ldr x1, [sp]\n"
                            result += "    add sp, sp, #16\n"

                            result += "    strb w0, [x1]\n"
                        }
                    }

                default:
                    result += try generatePushVariableAddress(identifierName: casted.identifierName, sourceIndex: casted.identifierToken.sourceIndex)
                    result += try generate(node: initializerExpr)

                    result += "    ldr x0, [sp]\n"
                    result += "    add sp, sp, #16\n"
                    result += "    ldr x1, [sp]\n"
                    result += "    add sp, sp, #16\n"

                    if getVariableType(name: casted.identifierName)?.memorySize == 1 {
                        result += "    strb w0, [x1]\n"
                    } else {
                        result += "    str x0, [x1]\n"
                    }
                }
            }

            return result

        case .arrayExpr:
            // variableDeclの右辺にのみ現れるため、variableDeclで処理
            fatalError()

        case .subscriptCallExpr:
            let casted = try node.casted(SubscriptCallExpressionNode.self)

            result += try generatePushArrayElementAddress(node: casted)

            // 結果のアドレスの値をロードしてスタックに積む
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifierNode.identifierName) {
                result += "    ldrb w0, [x0]\n"
            } else {
                result += "    ldr x0, [x0]\n"
            }
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

            for statement in casted.items {
                result += try generate(node: statement)

                // 次のstmtに行く前に今のstmtの最終結果を消す
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
            }

            return result

        case .blockItem:
            let casted = try node.casted(BlockItemNode.self)

            return try generate(node: casted.item)

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

        case .tupleExpr:
            let casted = try node.casted(TupleExpressionNode.self)
            return try generate(node: casted.expression)

        case .prefixOperatorExpr:
            let casted = try node.casted(PrefixOperatorExpressionNode.self)

            switch casted.operatorKind {
            case .plus:
                // +は影響がないのでそのまま
                result += try generate(node: casted.expression)

            case .minus:
                result += try generate(node: casted.expression)

                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // 符号反転
                result += "    neg x0, x0\n"

                result += "    str x0, [sp, #-16]!\n"

            case .reference:
                // *のあとはどんな値でも良い
                result += try generate(node: casted.expression)

                // 値をロードしてpush
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // 値をアドレスとして読み、アドレスが指す値をロード
                if let identifier = casted.expression as? IdentifierNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.identifierName) {
                    result += "    ldrb w0, [x0]\n"
                } else {
                    result += "    ldr x0, [x0]\n"
                }

                result += "    str x0, [sp, #-16]!\n"

            case .address:
                // &のあとは変数しか入らない（はず？）
                if let right = casted.expression as? IdentifierNode {
                    result += try generatePushVariableAddress(node: right)
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
                    result += try generatePushVariableAddress(node: casted.left.casted(IdentifierNode.self))
                } else if let pointer = casted.left as? PrefixOperatorExpressionNode, pointer.operatorKind == .reference {
                    result += try generate(node: pointer.expression)
                } else if let subscriptCall = casted.left as? SubscriptCallExpressionNode {
                    result += try generatePushArrayElementAddress(node: subscriptCall)
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
                if let identifier = casted.left as? IdentifierNode, getVariableType(name: identifier.identifierName)?.memorySize == 1 {
                    result += "    strb w0, [x1]\n"
                } else if let pointer = casted.left as? PrefixOperatorExpressionNode, pointer.operatorKind == .reference, let identifier = pointer.expression as? IdentifierNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.identifierName) {
                    result += "    strb w0, [x1]\n"
                } else if let subscriptCall = casted.left as? SubscriptCallExpressionNode,
                          isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCall.identifierNode.identifierName) {
                    result += "    strb w0, [x1]\n"
                } else {
                    result += "    str x0, [x1]\n"
                }

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
                    if let identifier = casted.left as? IdentifierNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.identifierName) {
                        result += "    lsl x0, x0, #3\n"
                    } else if let identifier = casted.right as? IdentifierNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.identifierName) {
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

    /// local or global variableから変数を検索する
    private func getVariableType(name: String) -> (any TypeNodeProtocol)? {
        if let type = variables[name]?.type {
            type
        } else if let type = globalVariables[name] {
            type
        } else {
            nil
        }
    }

    private func isElementOrReferenceTypeMemorySizeOf(_ size: Int, identifierName: String) -> Bool {
        guard let identifierType = getVariableType(name: identifierName) else { return false }

        if let pointerType = identifierType as? PointerTypeNode {
            return pointerType.referenceType.memorySize == size
        }

        if let arrayType = identifierType as? ArrayTypeNode {
            return arrayType.elementType.memorySize == size
        }

        return false
    }

    /// nameの変数のアドレスをスタックにpushするコードを生成する
    private func generatePushVariableAddress(node: IdentifierNode) throws -> String {
        try generatePushVariableAddress(identifierName: node.identifierName, sourceIndex: node.token.sourceIndex)
    }

    private func generatePushVariableAddress(identifierName: String, sourceIndex: Int) throws -> String {
        var result = ""

        if let localVariableInfo = variables[identifierName] {
            result += "    sub x0, x29, #\(localVariableInfo.addressOffset)\n"
        } else if globalVariables[identifierName] != nil {
            // addじゃなくてldrであってる？
            result += "    adrp x0, \(identifierName)@GOTPAGE\n"
            result += "    ldr x0, [x0, \(identifierName)@GOTPAGEOFF]\n"
        } else {
            throw GenerateError.noSuchVariable(varibaleName: identifierName, index: sourceIndex)
        }

        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    private func generatePushArrayElementAddress(node: SubscriptCallExpressionNode) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(node: node.identifierNode)
        result += try generate(node: node.argument)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: node.identifierNode.identifierName) as? ArrayTypeNode, arrayType.elementType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        } else if let pointerType = getVariableType(name: node.identifierNode.identifierName)  as? PointerTypeNode, pointerType.referenceType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        }

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

    private func generatePushArrayElementAddress(identifierName: String, index: Int, sourceIndex: Int) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(identifierName: identifierName, sourceIndex: sourceIndex)

        result += "    mov x0, #\(index)\n"
        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: identifierName) as? ArrayTypeNode, arrayType.elementType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        } else if let pointerType = getVariableType(name: identifierName)  as? PointerTypeNode, pointerType.referenceType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        }

        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        // identifierがポインタだった場合はアドレスが指す値にする
        if variables[identifierName]?.type.kind == .pointerType {
            result += "    ldr x1, [x1]\n"

        }

        // それらを足す
        result += "    add x0, x1, x0\n"

        result += "    str x0, [sp, #-16]!\n"

        return result
    }
}
