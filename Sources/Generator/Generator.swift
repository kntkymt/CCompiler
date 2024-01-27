import Parser
import Tokenizer

public enum GenerateError: Error {
    case invalidSyntax(location: SourceLocation)
    case noSuchVariable(varibaleName: String, location: SourceLocation)
}

extension SyntaxProtocol {
    func casted<T: SyntaxProtocol>(_ type: T.Type) throws -> T {
        guard let casted = self as? T else { throw GenerateError.invalidSyntax(location: self.sourceTokens.first!.sourceRange.start) }

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
        var type: any TypeSyntaxProtocol
        var addressOffset: Int
    }

    private var globalVariables: [String: any TypeSyntaxProtocol] = [:]
    private var variables: [String: VariableInfo] = [:]
    private var stringLiteralLabels: [String: String] = [:]
    private var functionLabels: Set<String> = Set()

    public init() {
    }

    // MARK: - Public

    public func generate(sourceFileSyntax: SourceFileSyntax) throws -> String {

        var dataSection = ""
        var functionDeclResult = ""
        for statement in sourceFileSyntax.statements {
            switch statement.item.kind {
            case .variableDecl:
                if dataSection.isEmpty {
                    dataSection += ".section    __DATA,__data\n"
                }

                let casted = try statement.item.casted(VariableDeclSyntax.self)
                dataSection += try generateGlobalVariableDecl(syntax: casted)

            case .functionDecl:
                let casted = try statement.item.casted(FunctionDeclSyntax.self)
                functionDeclResult += ".p2align 2\n"
                functionDeclResult += try generate(syntax: casted)

            default:
                throw GenerateError.invalidSyntax(location: statement.sourceTokens.first!.sourceRange.start)
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

    func generateGlobalVariableDecl(syntax: VariableDeclSyntax) throws -> String {
        globalVariables[syntax.identifier.text] = syntax.type

        var result = ""

        if let initializerExpr = syntax.initializerExpr {

            result += ".globl \(syntax.identifier.text)\n"
            if syntax.type.memorySize != 1 {
                result += ".p2align 3, 0x0\n"
            }
            result += "\(syntax.identifier.text):\n"

            switch initializerExpr.kind {
            case .integerLiteral:
                let sizeKind = syntax.type.memorySize == 1 ? "byte" : "quad"
                let value = try initializerExpr.casted(IntegerLiteralSyntax.self).literal.text
                result += "    .\(sizeKind) \(value)\n"

            case .stringLiteral:
                guard case .stringLiteral(let content) = try initializerExpr.casted(StringLiteralSyntax.self).literal.tokenKind else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceTokens.first!.sourceRange.start)
                }
                result += "    .asciz \"\(content)\"\n"

            case .prefixOperatorExpr:
                let prefixOperatorExpr = try initializerExpr.casted(PrefixOperatorExprSyntax.self)
                if prefixOperatorExpr.operatorKind == .address {
                    let value = try prefixOperatorExpr.expression.casted(IdentifierSyntax.self).baseName.text
                    result += "    .quad \(value)\n"
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceTokens.first!.sourceRange.start)
                }

            case .infixOperatorExpr:
                let infixOperator = try initializerExpr.casted(InfixOperatorExprSyntax.self)

                func generateAddressValue(referenceSyntax: any SyntaxProtocol, IntegerLiteralSyntax: any SyntaxProtocol) -> String? {
                    if let prefix = referenceSyntax as? PrefixOperatorExprSyntax,
                       prefix.operatorKind == .address,
                       let identifier = prefix.expression as? IdentifierSyntax,
                       let binaryOperator = infixOperator.operator as? BinaryOperatorSyntax,
                       (binaryOperator.operatorKind == .add || binaryOperator.operatorKind == .sub),
                       let integerLiteral = IntegerLiteralSyntax as? IntegerLiteralSyntax {
                        return "    .quad \(identifier.baseName.text) \(binaryOperator.operator.text) \(integerLiteral.literal.text)\n"
                    } else {
                        return nil
                    }
                }

                // 左右一方が「&変数」, 他方が「IntergerLiteral」のはず
                if let leftIsReference = generateAddressValue(referenceSyntax: infixOperator.left, IntegerLiteralSyntax: infixOperator.right) {
                    result += leftIsReference
                } else if let rightIsReference = generateAddressValue(referenceSyntax: infixOperator.right, IntegerLiteralSyntax: infixOperator.left) {
                    result += rightIsReference
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceTokens.first!.sourceRange.start)
                }

            default:
                throw GenerateError.invalidSyntax(location: initializerExpr.sourceTokens.first!.sourceRange.start)
            }
        } else {
            // Apple Clangでは初期化がない場合は.commじゃないとダメっぽい？
            let alignment = isElementOrReferenceTypeMemorySizeOf(1, identifierName: syntax.identifier.text) ? 0 : 3
            result += ".comm \(syntax.identifier.text),\(syntax.type.memorySize),\(alignment)\n"
        }

        return result
    }

    func generate(syntax: any SyntaxProtocol) throws -> String {
        var result = ""

        switch syntax.kind {
        case .integerLiteral:
            let casted = try syntax.casted(IntegerLiteralSyntax.self)
            result += "    mov x0, #\(casted.literal.text)\n"
            result += "    str x0, [sp, #-16]!\n"

            return result

        case .stringLiteral:
            // stringLiteral自体はグローバル領域に定義し
            // 式自体は先頭のポインタを表す
            let casted = try syntax.casted(StringLiteralSyntax.self)
            guard case .stringLiteral(let content) = casted.literal.tokenKind else {
                throw GenerateError.invalidSyntax(location: casted.sourceTokens.first!.sourceRange.start)
            }
            let label: String
            if let stringLabel = stringLiteralLabels[content] {
                label = stringLabel
            } else {
                let stringLabel = "strings\(stringLiteralLabels.count)"
                stringLiteralLabels[content] = stringLabel
                label = stringLabel
            }

            result += "    adrp x0, \(label)@GOTPAGE\n"
            result += "    ldr x0, [x0, \(label)@GOTPAGEOFF]\n"

            result += "    str x0, [sp, #-16]!\n"

            return result

        case .identifier:
            let casted = try syntax.casted(IdentifierSyntax.self)

            // アドレスをpush
            result += try generatePushVariableAddress(syntax: casted)

            // 配列の場合は先頭アドレスのまま返す
            // 配列以外の場合はアドレスの中身を返す
            if let variableType = getVariableType(name: casted.baseName.text), variableType.kind != .arrayType {
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
            let casted = try syntax.casted(FunctionCallExprSyntax.self)

            // 引数を評価してスタックに積む
            for argument in casted.arguments {
                result += try generate(syntax: argument)
            }

            // 引数を関数に引き渡すためレジスタに入れる
            // 結果はスタックに積まれているので番号は逆から
            // 例: call(a, b) -> x0: a, x1: b
            for registorIndex in (0..<casted.arguments.count).reversed() {
                result += "    ldr x\(registorIndex), [sp]\n"
                result += "    add sp, sp, #16\n"
            }

            let functionLabel = casted.identifier.text == "main" ? "_main" : casted.identifier.text
            result += "    bl \(functionLabel)\n"

            // 帰り値をpush
            result += "    str x0, [sp, #-16]!\n"

            return result

        case .exprListItem:
            let casted = try syntax.casted(ExprListItemSyntax.self)
            return try generate(syntax: casted.expression)

        case .functionDecl:
            let casted = try syntax.casted(FunctionDeclSyntax.self)

            // 関数定義ごとに作り直す
            variables = [:]

            let functionLabel = casted.functionName.text == "main" ? "_main" : casted.functionName.text
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
            for (index, parameter) in casted.parameters.enumerated() {
                let offset = (variables.count + 1) * 8
                variables[parameter.identifier.text] = VariableInfo(type: parameter.type, addressOffset: offset)

                parameterDecl += "    str x\(index), [x29, #-\(offset)]\n"
            }

            let body = try generate(syntax: casted.block)

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
            let casted = try syntax.casted(VariableDeclSyntax.self)

            let offset = variables.reduce(0) { $0 + $1.value.type.memorySize } + casted.type.memorySize
            variables[casted.identifier.text] = VariableInfo(type: casted.type, addressOffset: offset)

            if let initializerExpr = casted.initializerExpr {
                switch initializerExpr.kind {
                case .arrayExpr:
                    // = { }
                    let arrayExpr = try initializerExpr.casted(ArrayExprSyntax.self)

                    for (arrayIndex, element) in arrayExpr.exprListSyntaxs.enumerated() {
                        result += try generatePushArrayElementAddress(identifierName: casted.identifier.text, index: arrayIndex, sourceLocation: casted.identifier.token.sourceRange.start)
                        result += try generate(syntax: element)

                        result += "    ldr x0, [sp]\n"
                        result += "    add sp, sp, #16\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifier.text) {
                            result += "    strb w0, [x1]\n"
                        } else {
                            result += "    str x0, [x1]\n"
                        }
                    }

                    // { ... }の要素が足りなかったら0埋めする
                    let arrayType = try casted.type.casted(ArrayTypeSyntax.self)
                    if arrayExpr.exprListSyntaxs.count < arrayType.arrayLength {
                        for arrayIndex in arrayExpr.exprListSyntaxs.count..<arrayType.arrayLength {
                            result += try generatePushArrayElementAddress(identifierName: casted.identifier.text, index: arrayIndex, sourceLocation: casted.identifier.token.sourceRange.start)

                            result += "    mov x0, #0\n"
                            result += "    ldr x1, [sp]\n"
                            result += "    add sp, sp, #16\n"

                            if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifier.text) {
                                result += "    strb w0, [x1]\n"
                            } else {
                                result += "    str x0, [x1]\n"
                            }
                        }
                    }

                    return result

                case .stringLiteral:
                    // = ""
                    if casted.type is PointerTypeSyntax { fallthrough }

                    let StringLiteralSyntax = try initializerExpr.casted(StringLiteralSyntax.self)
                    guard case .stringLiteral(let content) = StringLiteralSyntax.literal.tokenKind else {
                        throw GenerateError.invalidSyntax(location: StringLiteralSyntax.literal.token.sourceRange.start)
                    }
                    for (arrayIndex, element) in content.enumerated() {
                        result += try generatePushArrayElementAddress(identifierName: casted.identifier.text, index: arrayIndex, sourceLocation: casted.identifier.token.sourceRange.start)

                        result += "    mov x0, #\(element.asciiValue ?? 0)\n"
                        result += "    ldr x1, [sp]\n"
                        result += "    add sp, sp, #16\n"

                        result += "    strb w0, [x1]\n"
                    }

                    // ""の要素が足りなかったら0埋めする
                    let arrayType = try casted.type.casted(ArrayTypeSyntax.self)
                    if content.count < arrayType.arrayLength {
                        for arrayIndex in content.count..<arrayType.arrayLength {
                            result += try generatePushArrayElementAddress(identifierName: casted.identifier.text, index: arrayIndex, sourceLocation: casted.identifier.token.sourceRange.start)

                            result += "    mov x0, #0\n"
                            result += "    ldr x1, [sp]\n"
                            result += "    add sp, sp, #16\n"

                            result += "    strb w0, [x1]\n"
                        }
                    }

                default:
                    result += try generatePushVariableAddress(identifierName: casted.identifier.text, sourceLocation: casted.identifier.token.sourceRange.start)
                    result += try generate(syntax: initializerExpr)

                    result += "    ldr x0, [sp]\n"
                    result += "    add sp, sp, #16\n"
                    result += "    ldr x1, [sp]\n"
                    result += "    add sp, sp, #16\n"

                    if getVariableType(name: casted.identifier.text)?.memorySize == 1 {
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
            let casted = try syntax.casted(SubscriptCallExprSyntax.self)

            result += try generatePushArrayElementAddress(syntax: casted)

            // 結果のアドレスの値をロードしてスタックに積む
            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            if isElementOrReferenceTypeMemorySizeOf(1, identifierName: casted.identifier.baseName.text) {
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
            let casted = try syntax.casted(BlockStatementSyntax.self)

            for statement in casted.items {
                result += try generate(syntax: statement)

                // 次のstmtに行く前に今のstmtの最終結果を消す
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
            }

            return result

        case .blockItem:
            let casted = try syntax.casted(BlockItemSyntax.self)

            return try generate(syntax: casted.item)

        case .returnStatement:
            let casted = try syntax.casted(ReturnStatementSyntax.self)

            // return結果をスタックにpush
            result += try generate(syntax: casted.expression)
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
            let casted = try syntax.casted(WhileStatementSyntax.self)
            let labelID = getLabelID()
            let beginLabel = ".Lbegin\(labelID)"
            let endLabel = ".Lend\(labelID)"

            result += "\(beginLabel):\n"

            result += try generate(syntax: casted.condition)

            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            result += "    cmp x0, #0\n"
            result += "    beq \(endLabel)\n"

            result += try generate(syntax: casted.body)

            result += "    b \(beginLabel)\n"

            result += "\(endLabel):\n"

            return result

        case .ifStatement:
            let casted = try syntax.casted(IfStatementSyntax.self)
            let labelID = getLabelID()
            let endLabel = ".Lend\(labelID)"

            result += try generate(syntax: casted.condition)

            result += "    ldr x0, [sp]\n"
            result += "    add sp, sp, #16\n"

            result += "    cmp x0, #0\n"

            if let falseBody = casted.falseBody {
                let elseLabel = ".Lelse\(labelID)"

                result += "    beq \(elseLabel)\n"
                result += try generate(syntax: casted.trueBody)
                result += "    b \(endLabel)\n"

                result += "\(elseLabel):\n"
                result += try generate(syntax: falseBody)

            } else {
                result += "    beq \(endLabel)\n"

                result += try generate(syntax: casted.trueBody)
            }

            result += "\(endLabel):\n"

            return result

        case .forStatement:
            let casted = try syntax.casted(ForStatementSyntax.self)

            let labelID = getLabelID()
            let beginLabel = ".Lbegin\(labelID)"
            let endLabel = ".Lend\(labelID)"

            if let preExpr = casted.pre {
                result += try generate(syntax: preExpr)
            }

            result += "\(beginLabel):\n"

            if let condition = casted.condition {
                result += try generate(syntax: condition)

                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
            } else {
                // 条件がない場合はtrue
                result += "    mov x0, #1\n"
            }

            result += "    cmp x0, #0\n"
            result += "    beq \(endLabel)\n"

            result += try generate(syntax: casted.body)

            if let postExpr = casted.post {
                result += try generate(syntax: postExpr)
            }

            result += "    b \(beginLabel)\n"

            result += "\(endLabel):\n"

            return result

        case .tupleExpr:
            let casted = try syntax.casted(TupleExprSyntax.self)
            return try generate(syntax: casted.expression)

        case .prefixOperatorExpr:
            let casted = try syntax.casted(PrefixOperatorExprSyntax.self)

            switch casted.operatorKind {
            case .plus:
                // +は影響がないのでそのまま
                result += try generate(syntax: casted.expression)

            case .minus:
                result += try generate(syntax: casted.expression)

                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // 符号反転
                result += "    neg x0, x0\n"

                result += "    str x0, [sp, #-16]!\n"

            case .reference:
                // *のあとはどんな値でも良い
                result += try generate(syntax: casted.expression)

                // 値をロードしてpush
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"

                // 値をアドレスとして読み、アドレスが指す値をロード
                if let identifier = casted.expression as? IdentifierSyntax, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName.text) {
                    result += "    ldrb w0, [x0]\n"
                } else {
                    result += "    ldr x0, [x0]\n"
                }

                result += "    str x0, [sp, #-16]!\n"

            case .address:
                // &のあとは変数しか入らない（はず？）
                if let right = casted.expression as? IdentifierSyntax {
                    result += try generatePushVariableAddress(syntax: right)
                } else {
                    throw GenerateError.invalidSyntax(location: syntax.sourceTokens[0].sourceRange.start)
                }

            case .sizeof:
                // FIXME: どうやって式の型を推測する？
                // 今はとりあえず固定で8
                result += "    mov x0, #8\n"
                result += "    str x0, [sp, #-16]!\n"
            }

            return result

        case .infixOperatorExpr:
            let casted = try syntax.casted(InfixOperatorExprSyntax.self)

            if casted.operator is AssignSyntax {
                // 左辺は変数, `*値`, subscriptCall
                if casted.left is IdentifierSyntax {
                    result += try generatePushVariableAddress(syntax: casted.left.casted(IdentifierSyntax.self))
                } else if let pointer = casted.left as? PrefixOperatorExprSyntax, pointer.operatorKind == .reference {
                    result += try generate(syntax: pointer.expression)
                } else if let subscriptCall = casted.left as? SubscriptCallExprSyntax {
                    result += try generatePushArrayElementAddress(syntax: subscriptCall)
                } else {
                    throw GenerateError.invalidSyntax(location: casted.left.sourceTokens[0].sourceRange.start)
                }

                result += try generate(syntax: casted.right)

                // 両方のノードの結果をpop
                // rightが先に取れるので x0, x1, x0の順番
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
                result += "    ldr x1, [sp]\n"
                result += "    add sp, sp, #16\n"

                // assign
                if let identifier = casted.left as? IdentifierSyntax, getVariableType(name: identifier.baseName.text)?.memorySize == 1 {
                    result += "    strb w0, [x1]\n"
                } else if let pointer = casted.left as? PrefixOperatorExprSyntax, pointer.operatorKind == .reference, let identifier = pointer.expression as? IdentifierSyntax, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName.text) {
                    result += "    strb w0, [x1]\n"
                } else if let subscriptCall = casted.left as? SubscriptCallExprSyntax,
                          isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCall.identifier.baseName.text) {
                    result += "    strb w0, [x1]\n"
                } else {
                    result += "    str x0, [x1]\n"
                }

                result += "    str x0, [sp, #-16]!\n"

            } else if let binaryOperator = casted.operator as? BinaryOperatorSyntax {
                result += try generate(syntax: casted.left)
                result += try generate(syntax: casted.right)

                // 両方のノードの結果をpop
                // rightが先に取れるので x0, x1, x0の順番
                result += "    ldr x0, [sp]\n"
                result += "    add sp, sp, #16\n"
                result += "    ldr x1, [sp]\n"
                result += "    add sp, sp, #16\n"

                if binaryOperator.operatorKind == .add || binaryOperator.operatorKind == .sub {
                    // addまたはsubの時、一方が変数でポインタ型または配列だったら、他方を8倍する
                    // 8は8バイト（ポインタの指すサイズ、今は全部8バイトなので）
                    if let identifier = casted.left as? IdentifierSyntax, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName.text) {
                        result += "    lsl x0, x0, #3\n"
                    } else if let identifier = casted.right as? IdentifierSyntax, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName.text) {
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
                throw GenerateError.invalidSyntax(location: syntax.sourceTokens[0].sourceRange.start)
            }

            return result

        case .binaryOperator:
            fatalError()

        case .assign:
            fatalError()

        case .sourceFile:
            fatalError()

        case .token:
            fatalError()
        }
    }

    // MARK: - Private

    /// local or global variableから変数を検索する
    private func getVariableType(name: String) -> (any TypeSyntaxProtocol)? {
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

        if let pointerType = identifierType as? PointerTypeSyntax {
            return pointerType.referenceType.memorySize == size
        }

        if let arrayType = identifierType as? ArrayTypeSyntax {
            return arrayType.elementType.memorySize == size
        }

        return false
    }

    /// nameの変数のアドレスをスタックにpushするコードを生成する
    private func generatePushVariableAddress(syntax: IdentifierSyntax) throws -> String {
        try generatePushVariableAddress(identifierName: syntax.baseName.text, sourceLocation: syntax.baseName.token.sourceRange.start)
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

    private func generatePushArrayElementAddress(syntax: SubscriptCallExprSyntax) throws -> String {
        var result = ""

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(syntax: syntax.identifier)
        result += try generate(syntax: syntax.argument)

        result += "    ldr x0, [sp]\n"
        result += "    add sp, sp, #16\n"
        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: syntax.identifier.baseName.text) as? ArrayTypeSyntax, arrayType.elementType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        } else if let pointerType = getVariableType(name: syntax.identifier.baseName.text)  as? PointerTypeSyntax, pointerType.referenceType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        }

        result += "    ldr x1, [sp]\n"
        result += "    add sp, sp, #16\n"

        // identifierがポインタだった場合はアドレスが指す値にする
        if variables[syntax.identifier.baseName.text]?.type.kind == .pointerType {
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
        if let arrayType = getVariableType(name: identifierName) as? ArrayTypeSyntax, arrayType.elementType.memorySize == 8 {
            result += "    lsl x0, x0, 3\n"
        } else if let pointerType = getVariableType(name: identifierName)  as? PointerTypeSyntax, pointerType.referenceType.memorySize == 8 {
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
