import Parser

extension SyntaxProtocol {
    func casted<T: SyntaxProtocol>(_ type: T.Type) -> T {
        return self as! T
    }
}

public enum ASTGenerator {

    public static func generate(sourceFileSyntax: SourceFileSyntax) -> SourceFileNode {
        SourceFileNode(statements: sourceFileSyntax.statements.map { generate(syntax: $0) }, sourceRange: sourceFileSyntax.sourceRange)
    }

    static func generate(integerLiteral: IntegerLiteralSyntax) -> IntegerLiteralNode {
        IntegerLiteralNode(literal: integerLiteral.literal.text, sourceRange: integerLiteral.sourceRange)
    }

    static func generate(declReference: DeclReferenceSyntax) -> DeclReferenceNode {
        DeclReferenceNode(baseName: declReference.baseName.text, sourceRange: declReference.sourceRange)
    }

    static func generate(stringLiteral: StringLiteralSyntax) -> StringLiteralNode {
        if case .stringLiteral(let content) = stringLiteral.literal.tokenKind {
            return StringLiteralNode(literal: content, sourceRange: stringLiteral.sourceRange)
        } else {
            fatalError()
        }
    }

    static func generate(typeProtocol: any TypeSyntaxProtocol) -> any TypeNodeProtocol {
        switch typeProtocol.kind {
        case .type: generate(type: typeProtocol.casted(TypeSyntax.self))
        case .pointerType: generate(pointerType: typeProtocol.casted(PointerTypeSyntax.self))
        default: fatalError()
        }
    }

    static func generate(type: TypeSyntax) -> TypeNode {
        let typeKind: TypeNode.TypeKind = switch type.type.tokenKind {
        case .type(.int): .int
        case .type(.char): .char
        default: fatalError()
        }

        return TypeNode(type: typeKind, sourceRange: type.sourceRange)
    }

    static func generate(pointerType: PointerTypeSyntax) -> PointerTypeNode {
        PointerTypeNode(referenceType: generate(typeProtocol: pointerType.referenceType), sourceRange: pointerType.sourceRange)
    }

    static func generate(prefixOperatorExpr: PrefixOperatorExprSyntax) -> PrefixOperatorExprNode {
        let prefixOperatorExpr = prefixOperatorExpr.casted(PrefixOperatorExprSyntax.self)
        let operatorKind: PrefixOperatorExprNode.OperatorKind = switch prefixOperatorExpr.`operator`.tokenKind {
        case .reserved(.add): .plus
        case .reserved(.sub): .minus
        case .reserved(.mul): .reference
        case .reserved(.and): .address
        case .keyword(.sizeof): .sizeof
        default: fatalError()
        }

        return PrefixOperatorExprNode(operator: operatorKind, expression: generate(syntax: prefixOperatorExpr.expression), sourceRange: prefixOperatorExpr.sourceRange)
    }

    static func generate(infixOperatorExpr: InfixOperatorExprSyntax) -> InfixOperatorExprNode {
        let operatorKind: InfixOperatorExprNode.OperatorKind = switch  infixOperatorExpr.operator.tokenKind {
        case .reserved(.add): .add
        case .reserved(.sub): .sub
        case .reserved(.mul): .mul
        case .reserved(.div): .div
        case .reserved(.equal): .equal
        case .reserved(.notEqual): .notEqual
        case .reserved(.lessThan): .lessThan
        case .reserved(.lessThanOrEqual): .lessThanOrEqual
        case .reserved(.greaterThan): .greaterThan
        case .reserved(.greaterThanOrEqual): .greaterThanOrEqual
        case .reserved(.assign): .assign
        default: fatalError()
        }

        return InfixOperatorExprNode(
            left: generate(syntax: infixOperatorExpr.left),
            operator: operatorKind,
            right: generate(syntax: infixOperatorExpr.right),
            sourceRange: infixOperatorExpr.sourceRange
        )
    }

    static func generate(functionCallExpr: FunctionCallExprSyntax) -> FunctionCallExprNode {
        FunctionCallExprNode(
            identifier: generate(declReference: functionCallExpr.identifier),
            arguments: functionCallExpr.arguments.map { generate(syntax: $0) },
            sourceRange: functionCallExpr.sourceRange
        )
    }

    static func generate(subscriptCallExpr: SubscriptCallExprSyntax) -> SubscriptCallExprNode {
        SubscriptCallExprNode(
            identifier: generate(declReference: subscriptCallExpr.identifier),
            argument: generate(syntax: subscriptCallExpr.argument),
            sourceRange: subscriptCallExpr.sourceRange
        )
    }

    static func generate(initListExpr: InitListExprSyntax) -> InitListExprNode {
        InitListExprNode(
            expressions: initListExpr.exprListItemSyntaxs.map { generate(syntax: $0) },
            sourceRange: initListExpr.sourceRange
        )
    }

    static func generate(tupleExpr: TupleExprSyntax) -> TupleExprNode {
        TupleExprNode(
            expression: generate(syntax: tupleExpr.expression),
            sourceRange: tupleExpr.sourceRange
        )
    }

    static func generate(ifStatement: IfStatementSyntax) -> IfStatementNode {
        IfStatementNode(
            condition: generate(syntax: ifStatement.condition),
            trueBody: generate(syntax: ifStatement.trueBody),
            falseBody: ifStatement.falseBody.map { generate(syntax: $0) },
            sourceRange: ifStatement.sourceRange
        )
    }

    static func generate(whileStatement: WhileStatementSyntax) -> WhileStatementNode {
        WhileStatementNode(
            condition: generate(syntax: whileStatement.condition),
            body: generate(syntax: whileStatement.body),
            sourceRange: whileStatement.sourceRange
        )
    }

    static func generate(forStatement: ForStatementSyntax) -> ForStatementNode {
        ForStatementNode(
            pre: forStatement.pre.map { generate(syntax: $0) },
            condition: forStatement.condition.map { generate(syntax: $0) },
            post: forStatement.post.map { generate(syntax: $0) },
            body: generate(syntax: forStatement.body), 
            sourceRange: forStatement.sourceRange
        )
    }

    static func generate(returnStatement: ReturnStatementSyntax) -> ReturnStatementNode {
        ReturnStatementNode(
            expression: generate(syntax: returnStatement.expression),
            sourceRange: returnStatement.sourceRange
        )
    }

    static func generate(blockStatement: BlockStatementSyntax) -> BlockStatementNode {
        BlockStatementNode(
            items: blockStatement.items.map { generate(syntax: $0) },
            sourceRange: blockStatement.sourceRange
        )
    }

    static func generate(functionDecl: FunctionDeclSyntax) -> FunctionDeclNode {
        FunctionDeclNode(
            returnType: generate(typeProtocol: functionDecl.returnType),
            functionName: functionDecl.functionName.text,
            parameters: functionDecl.parameters.map { generate(functionParameter: $0) },
            block: generate(blockStatement: functionDecl.block),
            sourceRange: functionDecl.sourceRange
        )
    }

    static func generate(functionParameter: FunctionParameterSyntax) -> FunctionParameterNode {
        let type: any TypeNodeProtocol
        if functionParameter.squareLeft != nil, functionParameter.squareRight != nil {
            // 関数の引数の配列はポインタと同じ扱い
            type = PointerTypeNode(referenceType: generate(typeProtocol: functionParameter.type), sourceRange: functionParameter.type.sourceRange)
        } else {
            type = generate(typeProtocol: functionParameter.type)
        }

        return FunctionParameterNode(
            type: type,
            identifierName: functionParameter.identifier.text,
            sourceRange: functionParameter.sourceRange
        )
    }

    static func generate(variableDecl: VariableDeclSyntax) -> VariableDeclNode {
        let type: any TypeNodeProtocol
        if variableDecl.squareLeft != nil,
           let arrayLength = variableDecl.arrayLength,
           variableDecl.squareRight != nil {
            type = ArrayTypeNode(
                elementType: generate(typeProtocol: variableDecl.type),
                arrayLength: Int(arrayLength.text)!,
                sourceRange: variableDecl.type.sourceRange
            )
        } else {
            type = generate(typeProtocol: variableDecl.type)
        }

        return VariableDeclNode(
            type: type,
            identifierName: variableDecl.identifier.text,
            initializerExpr: variableDecl.initializerExpr.map { generate(syntax: $0) },
            sourceRange: variableDecl.sourceRange
        )
    }

    // ExprListItem is removed on AST
    static func generate(exprListItem: ExprListItemSyntax) -> any NodeProtocol {
        generate(syntax: exprListItem.expression)
    }

    // BlockItem is removed on AST
    static func generate(blockItem: BlockItemSyntax) -> any NodeProtocol {
        generate(syntax: blockItem.item)
    }

    static func generate(syntax: any SyntaxProtocol) -> any NodeProtocol {
        switch syntax.kind {
        case .integerLiteral: generate(integerLiteral: syntax.casted(IntegerLiteralSyntax.self))
        case .declReference: generate(declReference: syntax.casted(DeclReferenceSyntax.self))
        case .stringLiteral: generate(stringLiteral: syntax.casted(StringLiteralSyntax.self))
        case .type: generate(type: syntax.casted(TypeSyntax.self))
        case .pointerType: generate(pointerType: syntax.casted(PointerTypeSyntax.self))
        case .prefixOperatorExpr: generate(prefixOperatorExpr: syntax.casted(PrefixOperatorExprSyntax.self))
        case .infixOperatorExpr: generate(infixOperatorExpr: syntax.casted(InfixOperatorExprSyntax.self))
        case .functionCallExpr: generate(functionCallExpr: syntax.casted(FunctionCallExprSyntax.self))
        case .subscriptCallExpr: generate(subscriptCallExpr: syntax.casted(SubscriptCallExprSyntax.self))
        case .initListExpr: generate(initListExpr: syntax.casted(InitListExprSyntax.self))
        case .tupleExpr: generate(tupleExpr: syntax.casted(TupleExprSyntax.self))
        case .ifStatement: generate(ifStatement: syntax.casted(IfStatementSyntax.self))
        case .whileStatement: generate(whileStatement: syntax.casted(WhileStatementSyntax.self))
        case .forStatement: generate(forStatement: syntax.casted(ForStatementSyntax.self))
        case .returnStatement: generate(returnStatement: syntax.casted(ReturnStatementSyntax.self))
        case .blockStatement: generate(blockStatement: syntax.casted(BlockStatementSyntax.self))
        case .functionDecl: generate(functionDecl: syntax.casted(FunctionDeclSyntax.self))
        case .functionParameter: generate(functionParameter: syntax.casted(FunctionParameterSyntax.self))
        case .variableDecl: generate(variableDecl: syntax.casted(VariableDeclSyntax.self))
        case .sourceFile: generate(sourceFileSyntax: syntax.casted(SourceFileSyntax.self))
        case .exprListItem: generate(exprListItem: syntax.casted(ExprListItemSyntax.self))
        case .blockItem: generate(blockItem: syntax.casted(BlockItemSyntax.self))
        case .token: fatalError()
        }
    }
}
