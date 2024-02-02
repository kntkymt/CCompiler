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
        var addressOffset: Int64
    }

    private var globalVariables: [String: any TypeNodeProtocol] = [:]
    private var localVariables: [String: VariableInfo] = [:]
    private var stringLiteralLabels: [String: String] = [:]
    private var functionLabels: Set<String> = Set()

    public init() {
    }

    // MARK: - Public

    public func generate(sourceFileNode: SourceFileNode) throws -> [AsmRepresent.Instruction] {

        var dataSection: [AsmRepresent.Instruction] = []
        var functionDeclResult: [AsmRepresent.Instruction] = []
        for statement in sourceFileNode.statements {
            switch statement.kind {
            case .variableDecl:
                if dataSection.isEmpty {
                    dataSection.append(.section(kinds: [.DATA,.data]))
                }

                let casted = statement.casted(VariableDeclNode.self)
                dataSection += try generateGlobalVariableDecl(node: casted)

            case .functionDecl:
                let casted = statement.casted(FunctionDeclNode.self)
                functionDeclResult += try generate(node: casted)

            default:
                fatalError()
            }
        }

        if !stringLiteralLabels.isEmpty {
            dataSection.append(.section(kinds: [.TEXT, .cstring, .cstring_literals]))
            for (literal, label) in stringLiteralLabels {
                dataSection.append(contentsOf: [
                    .label(label: label),
                    .dataDecl(kind: .asciz, value: "\"\(literal)\"")
                ])
            }
        }

        return functionDeclResult + dataSection
    }

    func generateGlobalVariableDecl(node: VariableDeclNode) throws -> [AsmRepresent.Instruction] {
        globalVariables[node.identifierName] = node.type

        var result: [AsmRepresent.Instruction] = []

        if let initializerExpr = node.initializerExpr {

            result.append(.globl(label: node.identifierName))
            if node.type.memorySize != 1 {
                result.append(.p2align(factor: 3))
            }
            result.append(.label(label: node.identifierName))

            switch initializerExpr.kind {
            case .integerLiteral:
                let value = initializerExpr.casted(IntegerLiteralNode.self).literal

                result.append(.dataDecl(kind: node.type.memorySize == 1 ? .byte : .quad, value: value))

            case .stringLiteral:
                let value = initializerExpr.casted(StringLiteralNode.self).literal
                result.append(.dataDecl(kind: .asciz, value: "\"\(value)\""))

            case .prefixOperatorExpr:
                let prefixOperatorExpr = initializerExpr.casted(PrefixOperatorExprNode.self)
                if prefixOperatorExpr.operator == .address {
                    let value = prefixOperatorExpr.expression.casted(DeclReferenceNode.self).baseName
                    result.append(.dataDecl(kind: .quad, value: value))
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
                }

            case .infixOperatorExpr:
                let infixOperator = initializerExpr.casted(InfixOperatorExprNode.self)

                func generateAddressValue(referenceNode: any NodeProtocol, IntegerLiteralNode: any NodeProtocol) -> AsmRepresent.Instruction? {
                    if let prefix = referenceNode as? PrefixOperatorExprNode,
                       prefix.operator == .address,
                       let identifier = prefix.expression as? DeclReferenceNode,
                       (infixOperator.operator == .add || infixOperator.operator == .sub),
                       let integerLiteral = IntegerLiteralNode as? IntegerLiteralNode {
                        return .dataDecl(kind: .quad, value: "\(identifier.baseName) \(infixOperator.operator.rawValue) \(integerLiteral.literal)")
                    } else {
                        return nil
                    }
                }

                // 左右一方が「&変数」, 他方が「IntergerLiteral」のはず
                if let leftIsReference = generateAddressValue(referenceNode: infixOperator.left, IntegerLiteralNode: infixOperator.right) {
                    result += [leftIsReference]
                } else if let rightIsReference = generateAddressValue(referenceNode: infixOperator.right, IntegerLiteralNode: infixOperator.left) {
                    result += [rightIsReference]
                } else {
                    throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
                }

            default:
                throw GenerateError.invalidSyntax(location: initializerExpr.sourceRange.start)
            }
        } else {
            // Apple Clangでは初期化がない場合は.commじゃないとダメっぽい？
            let alignment = isElementOrReferenceTypeMemorySizeOf(1, identifierName: node.identifierName) ? 0 : 3
            result.append(.dataDecl(kind: .comm, value: "\(node.identifierName),\(node.type.memorySize),\(alignment)"))
        }

        return result
    }

    func generate(integerLiteral: IntegerLiteralNode) -> [AsmRepresent.Instruction] {
        [
            .movi(dst: .x0, immediate: Int64(integerLiteral.literal)!),
            .push(src: .x0)
        ]
    }

    func generate(stringLiteral: StringLiteralNode) -> [AsmRepresent.Instruction] {
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

        return [
            .addr(dst: .x0, label: label),
            .push(src: .x0)
        ]
    }

    func generate(declReference: DeclReferenceNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        // アドレスをpush
        result += try generatePushVariableAddress(node: declReference)

        // 配列の場合は先頭アドレスのまま返す
        // 配列以外の場合はアドレスの中身を返す
        if let variableType = getVariableType(name: declReference.baseName), variableType.kind != .arrayType {
            // アドレスをpop
            result.append(.pop(dst: .x0))
            // アドレスを値に変換してpush
            if variableType.memorySize == 1 {
                result.append(.ldrb(dst: .w0, address: .register(.x0)))
            } else {
                result.append(.ldr(dst: .x0, address: .register(.x0)))
            }
            result.append(.push(src: .x0))
        }

        return result
    }

    func generate(functionCallExpr: FunctionCallExprNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        // 引数を評価してスタックに積む
        for argument in functionCallExpr.arguments {
            result += try generate(node: argument)
        }

        // 引数を関数に引き渡すためレジスタに入れる
        // 結果はスタックに積まれているので番号は逆から
        // 例: call(a, b) -> x0: a, x1: b
        for registorIndex in (0..<functionCallExpr.arguments.count).reversed() {
            result.append(.pop(dst: .x(registorIndex)))
        }

        result.append(.bl(label: functionCallExpr.identifier.baseName))

        // 帰り値をpush 帰り値はx0に入っている
        result.append(.push(src: .x0))

        return result
    }

    func generate(functionDecl: FunctionDeclNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        // 関数定義ごとに作り直す
        localVariables = [:]

        let functionLabel = functionDecl.functionName
        functionLabels.insert(functionLabel)

        result.append(contentsOf: [
            .p2align(factor: 2),
            .globl(label: functionLabel),
            .label(label: functionLabel)
        ])

        // プロローグ
        let prologue: [AsmRepresent.Instruction] = [
            .subi(dst: .sp, src: .sp, immediate: 16),
            // push 古いBR, 呼び出し元LR
            .stp(src1: .x29, src2: .x30, address: .register(.sp)),
            // 今のスタックのトップをBRに（新しい関数フレームを宣言）
            .mov(dst: .x29, src: .sp)
        ]

        var parameterDecl: [AsmRepresent.Instruction] = []
        // 引数をローカル変数として保存し直す
        for (index, parameter) in functionDecl.parameters.enumerated() {
            let offset = (localVariables.count + 1) * 8
            localVariables[parameter.identifierName] = VariableInfo(type: parameter.type, addressOffset: Int64(offset))

            parameterDecl.append(.str(src: .x(index), address: .distance(.x29, -Int64(offset))))
        }

        let body = try generate(node: functionDecl.block)

        // 確保するスタックの量はbodyを見てからじゃないとわからないので
        // body生成後のlocalVariableのサイズを見てprologueにスタック確保を追加する
        result += prologue
        if !localVariables.isEmpty {
            // FIXME: スタックのサイズは16の倍数...のはずだが32じゃないとダメっぽい？
            let variableSize = localVariables.reduce(0) { $0 + $1.value.type.memorySize }
            result.append(.subi(dst: .sp, src: .sp, immediate: Int64(variableSize.isMultiple(of: 64) ? variableSize : (1 + variableSize / 128) * 128)))
        }

        result += parameterDecl
        result += body

        return result
    }

    func generate(variableDecl: VariableDeclNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        let offset = localVariables.reduce(0) { $0 + $1.value.type.memorySize } + variableDecl.type.memorySize
        localVariables[variableDecl.identifierName] = VariableInfo(type: variableDecl.type, addressOffset: Int64(offset))

        if let initializerExpr = variableDecl.initializerExpr {
            switch initializerExpr.kind {
            case .initListExpr:
                // = { }
                let arrayExpr = initializerExpr.casted(InitListExprNode.self)

                for (arrayIndex, element) in arrayExpr.expressions.enumerated() {
                    result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)
                    result += try generate(node: element)

                    result.append(.pop(dst: .x0))
                    result.append(.pop(dst: .x1))

                    if getVariableType(name: variableDecl.identifierName)?.memorySize == 1 {
                        result.append(.strb(src: .w0, address: .register(.x1)))
                    } else {
                        result.append(.str(src: .x0, address: .register(.x1)))
                    }
                }

                // { ... }の要素が足りなかったら0埋めする
                let arrayType = variableDecl.type.casted(ArrayTypeNode.self)
                if arrayExpr.expressions.count < arrayType.arrayLength {
                    for arrayIndex in arrayExpr.expressions.count..<arrayType.arrayLength {
                        result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)

                        result.append(.movi(dst: .x0, immediate: 0))
                        result.append(.pop(dst: .x1))

                        if getVariableType(name: variableDecl.identifierName)?.memorySize == 1 {
                            result.append(.strb(src: .w0, address: .register(.x1)))
                        } else {
                            result.append(.str(src: .x0, address: .register(.x1)))
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

                    result.append(contentsOf: [
                        .movi(dst: .x0, immediate: Int64(element.asciiValue ?? 0)),
                        .pop(dst: .x1),
                        .strb(src: .w0, address: .register(.x1))
                    ])
                }

                // ""の要素が足りなかったら0埋めする
                let arrayType = variableDecl.type.casted(ArrayTypeNode.self)
                if stringLiteralNode.literal.count < arrayType.arrayLength {
                    for arrayIndex in stringLiteralNode.literal.count..<arrayType.arrayLength {
                        result += try generatePushArrayElementAddress(identifierName: variableDecl.identifierName, index: arrayIndex, sourceLocation: variableDecl.sourceRange.start)

                        result.append(contentsOf: [
                            .movi(dst: .x0, immediate: 0),
                            .pop(dst: .x1),
                            .strb(src: .w0, address: .register(.x1))
                        ])
                    }
                }

            default:
                result += try generatePushVariableAddress(identifierName: variableDecl.identifierName, sourceLocation: variableDecl.sourceRange.start)
                result += try generate(node: initializerExpr)

                result.append(contentsOf: [
                    .pop(dst: .x0),
                    .pop(dst: .x1)
                ])

                if getVariableType(name: variableDecl.identifierName)?.memorySize == 1 {
                    result.append(.strb(src: .w0, address: .register(.x1)))
                } else {
                    result.append(.str(src: .x0, address: .register(.x1)))
                }
            }
        }

        return result
    }

    func generate(subscriptCallExpr: SubscriptCallExprNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        // 配列の先頭アドレスをx0に
        result += try generatePushArrayElementAddress(node: subscriptCallExpr)
        result.append(.pop(dst: .x0))

        if isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCallExpr.identifier.baseName) {
            result.append(.ldrb(dst: .w0, address: .register(.x0)))
        } else {
            result.append(.ldr(dst: .x0, address: .register(.x0)))
        }

        result.append(.push(src: .x0))

        return  result
    }

    func generate(blockStatement: BlockStatementNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        for statement in blockStatement.items {
            result += try generate(node: statement)

            // 次のstmtに行く前に今のstmtの最終結果を消す
            result.append(.pop(dst: .x0))
        }

        return result
    }

    func generate(returnStatement: ReturnStatementNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        // return結果をx0に
        result += try generate(node: returnStatement.expression)
        result.append(.pop(dst: .x0))

        // エピローグ
        result.append(contentsOf: [
            // spを元の位置に戻す
            .mov(dst: .sp, src: .x29),
            // 古いBR, 古いLRを復帰
            .ldp(dst1: .x29, dst2: .x30, address: .register(.x29)),
            .addi(dst: .sp, src: .sp, immediate: 16),
            .ret
        ])

        return result
    }

    func generate(whileStatement: WhileStatementNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        result.append(.label(label: beginLabel))

        result += try generate(node: whileStatement.condition)

        result.append(contentsOf: [
            .pop(dst: .x0),
            .cmpi(src: .x0, immediate: 0),
            .beq(label: endLabel)
        ])

        result += try generate(node: whileStatement.body)

        result.append(contentsOf: [
            .b(label: beginLabel),
            .label(label: endLabel)
        ])

        return result
    }

    func generate(ifStatement: IfStatementNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []
        let labelID = getLabelID()
        let endLabel = ".Lend\(labelID)"

        result += try generate(node: ifStatement.condition)

        result.append(contentsOf: [
            .pop(dst: .x0),
            .cmpi(src: .x0, immediate: 0)
        ])

        if let falseBody = ifStatement.falseBody {
            let elseLabel = ".Lelse\(labelID)"

            result.append(.beq(label: elseLabel))
            result += try generate(node: ifStatement.trueBody)

            result.append(.b(label: endLabel))
            result.append(.label(label: elseLabel))

            result += try generate(node: falseBody)
        } else {
            result.append(.beq(label: endLabel))

            result += try generate(node: ifStatement.trueBody)
        }

        result.append(.label(label: endLabel))

        return result
    }

    func generate(forStatement: ForStatementNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        let labelID = getLabelID()
        let beginLabel = ".Lbegin\(labelID)"
        let endLabel = ".Lend\(labelID)"

        if let preExpr = forStatement.pre {
            result += try generate(node: preExpr)
        }

        result.append(.label(label: beginLabel))

        if let condition = forStatement.condition {
            result += try generate(node: condition)

            result.append(.pop(dst: .x0))
        } else {
            // 条件がない場合はtrue
            result.append(.movi(dst: .x0, immediate: 1))
        }

        result.append(contentsOf: [
            .cmpi(src: .x0, immediate: 0),
            .beq(label: endLabel)
        ])

        result += try generate(node: forStatement.body)

        if let postExpr = forStatement.post {
            result += try generate(node: postExpr)
        }

        result.append(.b(label: beginLabel))
        result.append(.label(label: endLabel))

        return result
    }

    func generate(tupleExpr: TupleExprNode) throws -> [AsmRepresent.Instruction] {
        try generate(node: tupleExpr.expression)
    }

    func generate(prefixOperatorExpr: PrefixOperatorExprNode) throws -> [AsmRepresent.Instruction] {
        switch prefixOperatorExpr.operator {
        case .plus:
            // +は影響がないのでそのまま
            return try generate(node: prefixOperatorExpr.expression)

        case .minus:
            var result: [AsmRepresent.Instruction] = []
            result += try generate(node: prefixOperatorExpr.expression)

            result.append(contentsOf: [
                .pop(dst: .x0),
                .neg(des: .x0, src: .x0),
                .push(src: .x0)
            ])

            return result

        case .reference:
            var result: [AsmRepresent.Instruction] = []
            // *のあとはどんな値でも良い
            result += try generate(node: prefixOperatorExpr.expression)

            result.append(.pop(dst: .x0))

            // 値をアドレスとして読み、アドレスが指す値をロード
            if let identifier = prefixOperatorExpr.expression as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName) {
                result.append(.ldrb(dst: .w0, address: .register(.x0)))
            } else {
                result.append(.ldr(dst: .x0, address: .register(.x0)))
            }

            result.append(.push(src: .x0))
            return result

        case .address:
            var result: [AsmRepresent.Instruction] = []
            // &のあとは変数しか入らない（はず？）
            if let right = prefixOperatorExpr.expression as? DeclReferenceNode {
                result += try generatePushVariableAddress(node: right)
            } else {
                throw GenerateError.invalidSyntax(location: prefixOperatorExpr.sourceRange.start)
            }

            return result

        case .sizeof:
            // FIXME: どうやって式の型を推測する？
            // 今はとりあえず固定で8
            return [
                .movi(dst: .x0, immediate: 8),
                .push(src: .x0)
            ]
        }
    }

    func generate(infixOperatorExpr: InfixOperatorExprNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

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
        result.append(contentsOf: [
            .pop(dst: .x0),
            .pop(dst: .x1)
        ])

        if infixOperatorExpr.operator == .add || infixOperatorExpr.operator == .sub {
            // addまたはsubの時、一方が変数でポインタ型または配列だったら、他方を8倍する
            // 8は8バイト（ポインタの指すサイズ、今は全部8バイトなので）
            if let identifier = infixOperatorExpr.left as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName) {
                result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
            } else if let identifier = infixOperatorExpr.right as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(8, identifierName: identifier.baseName) {
                result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
            }
        }

        switch infixOperatorExpr.operator {
        case .assign:
            if let identifier = infixOperatorExpr.left as? DeclReferenceNode, getVariableType(name: identifier.baseName)?.memorySize == 1 {
                result.append(.strb(src: .w0, address: .register(.x1)))
            } else if let pointer = infixOperatorExpr.left as? PrefixOperatorExprNode, pointer.operator == .reference, let identifier = pointer.expression as? DeclReferenceNode, isElementOrReferenceTypeMemorySizeOf(1, identifierName: identifier.baseName) {
                result.append(.strb(src: .w0, address: .register(.x1)))
            } else if let subscriptCall = infixOperatorExpr.left as? SubscriptCallExprNode,
                      isElementOrReferenceTypeMemorySizeOf(1, identifierName: subscriptCall.identifier.baseName) {
                result.append(.strb(src: .w0, address: .register(.x1)))
            } else {
                result.append(.str(src: .x0, address: .register(.x1)))
            }

            result.append(.push(src: .x0))

        case .add:
            result.append(.add(dst: .x0, src1: .x1, src2: .x0))

        case .sub:
            result.append(.sub(dst: .x0, src1: .x1, src2: .x0))

        case .mul:
            result.append(.mul(dst: .x0, src1: .x1, src2: .x0))

        case .div:
            result.append(.div(dst: .x0, src1: .x1, src2: .x0))

        case .equal:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .eq)
            ])

        case .notEqual:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .ne)
            ])

        case .lessThan:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .lt)
            ])

        case .lessThanOrEqual:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .le)
            ])

        case .greaterThan:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .gt)
            ])

        case .greaterThanOrEqual:
            result.append(contentsOf: [
                .cmp(src1: .x1, src2: .x0),
                .cset(dst: .x0, flag: .ge)
            ])
        }

        if case .assign = infixOperatorExpr.operator {
        } else {
            result.append(.push(src: .x0))
        }

        return result
    }

    func generate(node: any NodeProtocol) throws -> [AsmRepresent.Instruction] {
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
        if let type = localVariables[name]?.type {
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
    private func generatePushVariableAddress(node: DeclReferenceNode) throws -> [AsmRepresent.Instruction] {
        try generatePushVariableAddress(identifierName: node.baseName, sourceLocation: node.sourceRange.start)
    }

    private func generatePushVariableAddress(identifierName: String, sourceLocation: SourceLocation) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        if let localVariableInfo = localVariables[identifierName] {
            result.append(.subi(dst: .x0, src: .x29, immediate: localVariableInfo.addressOffset))
        } else if globalVariables[identifierName] != nil {
            result.append(.addr(dst: .x0, label: identifierName))
        } else {
            throw GenerateError.noSuchVariable(varibaleName: identifierName, location: sourceLocation)
        }

        result.append(.push(src: .x0))

        return result
    }

    private func generatePushArrayElementAddress(node: SubscriptCallExprNode) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(node: node.identifier)
        result += try generate(node: node.argument)

        result.append(.pop(dst: .x0))

        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: node.identifier.baseName) as? ArrayTypeNode, arrayType.elementType.memorySize == 8 {
            result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
        } else if let pointerType = getVariableType(name: node.identifier.baseName)  as? PointerTypeNode, pointerType.referenceType.memorySize == 8 {
            result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
        }

        result.append(.pop(dst: .x1))

        // identifierがポインタだった場合はアドレスが指す値にする
        if localVariables[node.identifier.baseName]?.type.kind == .pointerType {
            result.append(.ldr(dst: .x1, address: .register(.x1)))

        }

        // それらを足す
        result.append(contentsOf: [
            .add(dst: .x0, src1: .x1, src2: .x0),
            .push(src: .x0)
        ])

        return result
    }

    private func generatePushArrayElementAddress(identifierName: String, index: Int, sourceLocation: SourceLocation) throws -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        // 配列の先頭アドレス, subscriptの値をpush
        result += try generatePushVariableAddress(identifierName: identifierName, sourceLocation: sourceLocation)

        result.append(.movi(dst: .x0, immediate: Int64(index)))
        // subscript内の値は要素のメモリサイズに応じてn倍する
        if let arrayType = getVariableType(name: identifierName) as? ArrayTypeNode, arrayType.elementType.memorySize == 8 {
            result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
        } else if let pointerType = getVariableType(name: identifierName)  as? PointerTypeNode, pointerType.referenceType.memorySize == 8 {
            result.append(.lsli(dst: .x0, src: .x0, immediate: 3))
        }

        result.append(.pop(dst: .x1))

        // identifierがポインタだった場合はアドレスが指す値にする
        if localVariables[identifierName]?.type.kind == .pointerType {
            result.append(.ldr(dst: .x1, address: .register(.x1)))
        }

        // それらを足す
        result.append(contentsOf: [
            .add(dst: .x0, src1: .x1, src2: .x0),
            .push(src: .x0)
        ])

        return result
    }
}
