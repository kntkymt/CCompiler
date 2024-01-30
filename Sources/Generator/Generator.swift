import AST
import Tokenizer

public enum GenerateError: Error {
    case invalidSyntax(location: SourceLocation)
    case noSuchVariable(varibaleName: String, location: SourceLocation)
}

extension NodeProtocol {
    func casted<T: NodeProtocol>(_ type: T.Type) -> T {
        return self as! T
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
            switch statement.kind {
            case .variableDecl:
                if dataSection.isEmpty {
                    dataSection += ".section    __DATA,__data\n"
                }

                let casted = statement.casted(VariableDeclNode.self)
                dataSection += try generateGlobalVariableDecl(node: casted)

            case .functionDecl:
                let casted = statement.casted(FunctionDeclNode.self)
                functionDeclResult += ".p2align 2\n"
                functionDeclResult += try generate(node: casted)

            default:
                fatalError()
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
                let value = initializerExpr.casted(IntegerLiteralNode.self).literal
                result += "    .\(sizeKind) \(value)\n"

            case .stringLiteral:
                let value = initializerExpr.casted(StringLiteralNode.self).literal
                result += "    .asciz \"\(value)\"\n"

            case .prefixOperatorExpr:
                let prefixOperatorExpr = initializerExpr.casted(PrefixOperatorExprNode.self)
                if prefixOperatorExpr.operator == .address {
                    let value = prefixOperatorExpr.expression.casted(DeclReferenceNode.self).baseName
                    result += "    .quad \(value)\n"
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
                }

            case .infixOperatorExpr:
                let infixOperator = initializerExpr.casted(InfixOperatorExprNode.self)

                func generateAddressValue(referenceNode: any NodeProtocol, IntegerLiteralNode: any NodeProtocol) -> String? {
                    if let prefix = referenceNode as? PrefixOperatorExprNode,
                       prefix.operator == .address,
                       let identifier = prefix.expression as? DeclReferenceNode,
                       (infixOperator.operator == .add || infixOperator.operator == .sub),
                       let integerLiteral = IntegerLiteralNode as? IntegerLiteralNode {
                        return "    .quad \(identifier.baseName) \(infixOperator.operator.rawValue) \(integerLiteral.literal)\n"
                    } else {
                        return nil
                    }
                }

                // 左右一方が「&変数」, 他方が「IntergerLiteral」のはず
                if let leftIsReference = generateAddressValue(referenceNode: infixOperator.left, IntegerLiteralNode: infixOperator.right) {
                    result += leftIsReference
                } else if let rightIsReference = generateAddressValue(referenceNode: infixOperator.right, IntegerLiteralNode: infixOperator.left) {
                    result += rightIsReference
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
                }

            default:
                throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
            }
        } else {
            // Apple Clangでは初期化がない場合は.commじゃないとダメっぽい？
            let alignment = isElementOrReferenceTypeMemorySizeOf(1, identifierName: node.identifierName) ? 0 : 3
            result += ".comm \(node.identifierName),\(node.type.memorySize),\(alignment)\n"
        }

        return result
    }

    func generate(integerLiteral: IntegerLiteralNode) -> String {
        var result = ""
        result += "    mov x0, #\(integerLiteral.literal)\n"
        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    func generate(stringLiteral: StringLiteralNode) -> String {
        var result = ""
        // stringLiteral自体はグローバル領域に定義し
        // 式自体は先頭のポインタを表す
        let label: String
        if let stringLabel = stringLiteralLabels[stringLiteral.literal] {
            label = stringLabel
        } else {
            let stringLabel = "strings\(stringLiteralLabels.count)"
            stringLiteralLabels[stringLiteral.literal] = stringLabel
            label = stringLabel
        }

        result += "    adrp x0, \(label)@GOTPAGE\n"
        result += "    ldr x0, [x0, \(label)@GOTPAGEOFF]\n"

        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    func generate(declReference: DeclReferenceNode) throws -> String {
        var result = ""
        // アドレスをpush
        result += try generatePushVariableAddress(node: declReference)

        // 配列の場合は先頭アドレスのまま返す
        // 配列以外の場合はアドレスの中身を返す
        if let variableType = getVariableType(name: declReference.baseName), variableType.kind != .arrayType {
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
    }

    func generate(functionCallExpr: FunctionCallExprNode) throws -> String {
        var result = ""
        // 引数を評価してスタックに積む
        for argument in functionCallExpr.arguments {
            result += try generate(node: argument)
        }

        // 引数を関数に引き渡すためレジスタに入れる
        // 結果はスタックに積まれているので番号は逆から
        // 例: call(a, b) -> x0: a, x1: b
        for registorIndex in (0..<functionCallExpr.arguments.count).reversed() {
            result += "    ldr x\(registorIndex), [sp]\n"
            result += "    add sp, sp, #16\n"
        }

        let functionLabel = functionCallExpr.identifier.baseName == "main" ? "_main" : functionCallExpr.identifier.baseName
        result += "    bl \(functionLabel)\n"

        // 帰り値をpush
        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    func generate(functionDecl: FunctionDeclNode) throws -> String {
        var result = ""
        // 関数定義ごとに作り直す
        variables = [:]

        let functionLabel = functionDecl.functionName == "main" ? "_main" : functionDecl.functionName
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
        for (index, parameter) in functionDecl.parameters.enumerated() {
            let offset = (variables.count + 1) * 8
            variables[parameter.identifierName] = VariableInfo(type: parameter.type, addressOffset: offset)

            parameterDecl += "    str x\(index), [x29, #-\(offset)]\n"
        }

        let body = try generate(node: functionDecl.block)

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
    }

    func generate(variableDecl: VariableDeclNode) throws -> String {
        var result = ""
        let offset = variables.reduce(0) { $0 + $1.value.type.memorySize } + variableDecl.type.memorySize
        variables[variableDecl.identifierName] = VariableInfo(type: variableDecl.type, addressOffset: offset)

        if let initializerExpr = variableDecl.initializerExpr {
            switch initializerExpr.kind {
            case .initListExpr:
                // = { }
                let arrayExpr = initializerExpr.casted(InitListExprNode.self)

                for (arrayIndex, element) in arrayExpr.expressions.enumerated() {
                    result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)
                    result += try generate(node: element)

                    result += "    ldr x0, [sp]\n"
                    result += "    add sp, sp, #16\n"
                    result += "    ldr x1, [sp]\n"
                    result += "    add sp, sp, #16\n"

                    if isElementOrReferenceTypeMemorySizeOf(1, identifierName: variableDecl.identifierName) {
                        result += "    strb w0, [x1]\n"
                    } else {
                        result += "    str x0, [x1]\n"
                    }
                }

                // { ... }の要素が足りなかったら0埋めする
                let arrayType = variableDecl.type.casted(ArrayTypeNode.self)
                if arrayExpr.expressions.count < arrayType.arrayLength {
                    for arrayIndex in arrayExpr.expressions.count..<arrayType.arrayLength {
                        result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)

                        result += "    mov x0, #0\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        if isElementOrReferenceTypeMemorySizeOf(1, identifierName: variableDecl.identifierName) {
                            result += "    strb w0, [x1]\n"
                        } else {
                            result += "    str x0, [x1]\n"
                        }
                    }
                }

                return result

            case .stringLiteral:
                // = ""
                if variableDecl.type is PointerTypeNode { fallthrough }

                let stringLiteralNode = initializerExpr.casted(StringLiteralNode.self)
                for (arrayIndex, element) in stringLiteralNode.literal.enumerated() {
                    result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)

                    result += "    mov x0, #\(element.asciiValue ?? 0)\n"
                    result += "    ldr x1, [sp]\n"
                    result += "    add sp, sp, #16\n"

                    result += "    strb w0, [x1]\n"
                }

                // ""の要素が足りなかったら0埋めする
                let arrayType = variableDecl.type.casted(ArrayTypeNode.self)
                if stringLiteralNode.literal.count < arrayType.arrayLength {
                    for arrayIndex in stringLiteralNode.literal.count..<arrayType.arrayLength {
                        result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)

                        result += "    mov x0, #0\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        result += "    strb w0, [x1]\n"
                    }
                }

            default:
                result += try generatePushVariableAddress(identifierName: variableDecl.identifierName, sourceLocation: variableDecl.sourceRange.start)
                result += try generate(node: initializerExpr)

                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
                result += "    ldr x1, [sp]\n"
                result += "    add sp, sp, #16\n"

                if getVariableType(name: variableDecl.identifierName)?.memorySize == 1 {
                    result += "    strb w0, [x1]\n"
                } else {
                    result += "    str x0, [x1]\n"
                }
            }
        }

        return result
    }

    func generate(subscriptCallExpr: SubscriptCallExprNode) throws -> String {
        var result = ""
        result += try generatePushArrayElementAddress(node: subscriptCallExpr)

        // 結果のアドレスの値をロードしてスタックに積む
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        if isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCallExpr.identifier.baseName) {
            result += "    ldrb w0, [x0]\n"
        } else {
            result += "    ldr x0, [x0]\n"
        }
        result += "    str x0, [sp, #-16]!\n"

        return  result
    }

    func generate(blockStatement: BlockStatementNode) throws -> String {
        var result = ""
        for statement in blockStatement.items {
            result += try generate(node: statement)

            // 次のstmtに行く前に今のstmtの最終結果を消す
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
        }

        return result
    }

    func generate(returnStatement: ReturnStatementNode) throws -> String {
        var result = ""

        // return結果をスタックにpush
        result += try generate(node: returnStatement.expression)
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
    }

    func generate(whileStatement: WhileStatementNode) throws -> String {
        var result = ""
        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        result += "\(beginLabel):\n"

        result += try generate(node: whileStatement.condition)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        result += "    cmp x0, #0\n"
        result += "    beq \(endLabel)\n"

        result += try generate(node: whileStatement.body)

        result += "    b \(beginLabel)\n"

        result += "\(endLabel):\n"

        return result
    }

    func generate(ifStatement: IfStatementNode) throws -> String {
        var result = ""
        let labelID = getLabelID()
        let endLabel = ".Lend\(labelID)"

        result += try generate(node: ifStatement.condition)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"

        result += "    cmp x0, #0\n"

        if let falseBody = ifStatement.falseBody {
            let elseLabel = ".Lelse\(labelID)"

            result += "    beq \(elseLabel)\n"
            result += try generate(node: ifStatement.trueBody)
            result += "    b \(endLabel)\n"

            result += "\(elseLabel):\n"
            result += try generate(node: falseBody)

        } else {
            result += "    beq \(endLabel)\n"

            result += try generate(node: ifStatement.trueBody)
        }

        result += "\(endLabel):\n"

        return result
    }

    func generate(forStatement: ForStatementNode) throws -> String {
        var result = ""

        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        if let preExpr = forStatement.pre {
            result += try generate(node: preExpr)
        }

        result += "\(beginLabel):\n"

        if let condition = forStatement.condition {
            result += try generate(node: condition)

            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"
        } else {
            // 条件がない場合はtrue
            result += "    mov x0, #1\n"
        }

        result += "    cmp x0, #0\n"
        result += "    beq \(endLabel)\n"

        result += try generate(node: forStatement.body)

        if let postExpr = forStatement.post {
            result += try generate(node: postExpr)
        }

        result += "    b \(beginLabel)\n"

        result += "\(endLabel):\n"

        return result
    }

    func generate(tupleExpr: TupleExprNode) throws -> String {
        try generate(node: tupleExpr.expression)
    }

    func generate(prefixOperatorExpr: PrefixOperatorExprNode) throws -> String {
        var result = ""

        switch prefixOperatorExpr.operator {
        case .plus:
            // +は影響がないのでそのまま
            result += try generate(node: prefixOperatorExpr.expression)

        case .minus:
            result += try generate(node: prefixOperatorExpr.expression)

            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            // 符号反転
            result += "    neg x0, x0\n"

            result += "    str x0, [sp, #-16]!\n"

        case .reference:
            // *のあとはどんな値でも良い
            result += try generate(node: prefixOperatorExpr.expression)

            // 値をロードしてpush
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            // 値をアドレスとして読み、アドレスが指す値をロード
            if let identifier = prefixOperatorExpr.expression as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName) {
                result += "    ldrb w0, [x0]\n"
            } else {
                result += "    ldr x0, [x0]\n"
            }

            result += "    str x0, [sp, #-16]!\n"

        case .address:
            // &のあとは変数しか入らない（はず？）
            if let right = prefixOperatorExpr.expression as? DeclReferenceNode {
                result += try generatePushVariableAddress(node: right)
            } else {
                throw GenerateError.invalidSyntax(location: prefixOperatorExpr.sourceRange.start)
            }

        case .sizeof:
            // FIXME: どうやって式の型を推測する？
            // 今はとりあえず固定で8
            result += "    mov x0, #8\n"
            result += "    str x0, [sp, #-16]!\n"
        }

        return result
    }

    func generate(infixOperatorExpr: InfixOperatorExprNode) throws -> String {
        var result = ""

        if case .assign = infixOperatorExpr.operator {
            // 左辺は変数, `*値`, subscriptCall
            if infixOperatorExpr.left is DeclReferenceNode {
                result += try generatePushVariableAddress(node: infixOperatorExpr.left.casted(DeclReferenceNode.self))
            } else if let pointer = infixOperatorExpr.left as? PrefixOperatorExprNode, pointer.operator == .reference {
                result += try generate(node: pointer.expression)
            } else if let subscriptCall = infixOperatorExpr.left as? SubscriptCallExprNode {
                result += try generatePushArrayElementAddress(node: subscriptCall)
            } else {
                throw GenerateError.invalidSyntax(location: infixOperatorExpr.left.sourceRange.start)
            }
        } else {
            result += try generate(node: infixOperatorExpr.left)
        }

        result += try generate(node: infixOperatorExpr.right)

        // 両方のノードの結果をpop
        // rightが先に取れるので x0, x1, x0の順番
        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        if infixOperatorExpr.operator == .add || infixOperatorExpr.operator == .sub {
            // addまたはsubの時、一方が変数でポインタ型または配列だったら、他方を8倍する
            // 8は8バイト（ポインタの指すサイズ、今は全部8バイトなので）
            if let identifier = infixOperatorExpr.left as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName) {
                result += "    lsl x0, x0, #3\n"
            } else if let identifier = infixOperatorExpr.right as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName) {
                result += "    lsl x1, x1, #3\n"
            }
        }

        switch infixOperatorExpr.operator {
        case .assign:
            if let identifier = infixOperatorExpr.left as? DeclReferenceNode, getVariableType(name: identifier.baseName)?.memorySize == 1 {
                result += "    strb w0, [x1]\n"
            } else if let pointer = infixOperatorExpr.left as? PrefixOperatorExprNode, pointer.operator == .reference, let identifier = pointer.expression as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName) {
                result += "    strb w0, [x1]\n"
            } else if let subscriptCall = infixOperatorExpr.left as? SubscriptCallExprNode,
                      isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCall.identifier.baseName) {
                result += "    strb w0, [x1]\n"
            } else {
                result += "    str x0, [x1]\n"
            }

            result += "    str x0, [sp, #-16]!\n"

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

        if case .assign = infixOperatorExpr.operator {
        } else {
            result += "    str x0, [sp, #-16]!\n"
        }

        return result
    }

    func generate(node: any NodeProtocol) throws -> String {
        switch node.kind {
        case .integerLiteral: generate(integerLiteral: node.casted(IntegerLiteralNode.self))
        case .stringLiteral: generate(stringLiteral: node.casted(StringLiteralNode.self))
        case .declReference: try generate(declReference: node.casted(DeclReferenceNode.self))
        case .functionCallExpr: try generate(functionCallExpr: node.casted(FunctionCallExprNode.self))
        case .functionDecl: try generate(functionDecl: node.casted(FunctionDeclNode.self))
        case .functionParameter: fatalError() // functionDeclにのみ現れるため、functionDeclで処理
        case .variableDecl: try generate(variableDecl: node.casted(VariableDeclNode.self))
        case .initListExpr: fatalError() // variableDeclの右辺にのみ現れるため、variableDeclで処理
        case .subscriptCallExpr: try generate(subscriptCallExpr: node.casted(SubscriptCallExprNode.self))
        case .arrayType: fatalError() // 現在型の一致を見ていない
        case .pointerType: fatalError()
        case .type: fatalError()
        case .blockStatement: try generate(blockStatement: node.casted(BlockStatementNode.self))
        case .returnStatement: try generate(returnStatement: node.casted(ReturnStatementNode.self))
        case .whileStatement: try generate(whileStatement: node.casted(WhileStatementNode.self))
        case .ifStatement: try generate(ifStatement: node.casted(IfStatementNode.self))
        case .forStatement: try generate(forStatement: node.casted(ForStatementNode.self))
        case .tupleExpr: try generate(tupleExpr: node.casted(TupleExprNode.self))
        case .prefixOperatorExpr: try generate(prefixOperatorExpr: node.casted(PrefixOperatorExprNode.self))
        case .infixOperatorExpr: try generate(infixOperatorExpr: node.casted(InfixOperatorExprNode.self))
        case .sourceFile: try generate(sourceFileNode: node.casted(SourceFileNode.self))
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
    private func generatePushVariableAddress(node: DeclReferenceNode) throws -> String {
        try generatePushVariableAddress(identifierName: node.baseName, sourceLocation: node.sourceRange.start)
    }

    private func generatePushVariableAddress(identifierName: String, sourceLocation: SourceLocation) throws -> String {
        var result = ""

        if let localVariableInfo = variables[identifierName] {
            result += "    sub x0, x29, #\(localVariableInfo.addressOffset)\n"
        } else if globalVariables[identifierName] != nil {
            // addじゃなくてldrであってる？
            result += "    adrp x0, \(identifierName)@GOTPAGE\n"
            result += "    ldr x0, [x0, \(identifierName)@GOTPAGEOFF]\n"
        } else {
            throw GenerateError.noSuchVariable(varibaleName: identifierName, location: sourceLocation)
        }

        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    private func generatePushArrayElementAddress(node: SubscriptCallExprNode) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(node: node.identifier)
        result += try generate(node: node.argument)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: node.identifier.baseName) as? ArrayTypeNode, arrayType.elementType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        } else if let pointerType = getVariableType(name: node.identifier.baseName)  as? PointerTypeNode, pointerType.referenceType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        }

        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        // identifierがポインタだった場合はアドレスが指す値にする
        if variables[node.identifier.baseName]?.type.kind == .pointerType {
            result += "    ldr x1, [x1]\n"

        }

        // それらを足す
        result += "    add x0, x1, x0\n"

        result += "    str x0, [sp, #-16]!\n"

        return result
    }

    private func generatePushArrayElementAddress(identifierName: String, index: Int, sourceLocation: SourceLocation) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(identifierName: identifierName, sourceLocation: sourceLocation)

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
