import Parser

extension SyntaxProtocol {
    func casted<T: SyntaxProtocol>(_ type: T.Type) -> T {
        return self as! T
    }
}

public struct ASTGenerator {

    public init() {}

    public func generate(_ sourceFileSyntax: SourceFileSyntax) -> SourceFileNode {
        SourceFileNode(statements: sourceFileSyntax.statements.map { generate($0) }, sourceRange: sourceFileSyntax.sourceRange)
    }

    func generate(_ integerLiteral: IntegerLiteralSyntax) -> IntegerLiteralNode {
        IntegerLiteralNode(literal: integerLiteral.literal.text, sourceRange: integerLiteral.sourceRange)
    }

    func generate(_ declReference: DeclReferenceSyntax) -> DeclReferenceNode {
        DeclReferenceNode(baseName: declReference.baseName.text, sourceRange: declReference.sourceRange)
    }

    func generate(_ stringLiteral: StringLiteralSyntax) -> StringLiteralNode {
        if case .stringLiteral(let content) = stringLiteral.literal.tokenKind {
            return StringLiteralNode(literal: content, sourceRange: stringLiteral.sourceRange)
        } else {
            fatalError()
        }
    }

    func generate(_ type: any TypeSyntaxProtocol) -> any TypeNodeProtocol {
        switch type.kind {
        case .type: generate(type.casted(TypeSyntax.self))
        case .pointerType: generate(type.casted(PointerTypeSyntax.self))
        case .arrayType: generate(type.casted(ArrayTypeSyntax.self))
        default: fatalError()
        }
    }

    func generate(_ type: TypeSyntax) -> TypeNode {
        let typeKind: TypeNode.TypeKind = switch type.type.tokenKind {
        case .type(.int): .int
        case .type(.char): .char
        default: fatalError()
        }

        return TypeNode(type: typeKind, sourceRange: type.sourceRange)
    }

    func generate(_ pointerType: PointerTypeSyntax) -> PointerTypeNode {
        PointerTypeNode(referenceType: generate(pointerType.referenceType), sourceRange: pointerType.sourceRange)
    }

    func generate(_ arrayType: ArrayTypeSyntax) -> ArrayTypeNode {
        ArrayTypeNode(elementType: generate(arrayType.elementType), arrayLength: arrayType.arrayLength, sourceRange: arrayType.sourceRange)
    }

    func generate(_ prefixOperatorExpr: PrefixOperatorExprSyntax) -> PrefixOperatorExprNode {
        let prefixOperatorExpr = prefixOperatorExpr.casted(PrefixOperatorExprSyntax.self)
        let operatorKind: PrefixOperatorExprNode.OperatorKind = switch prefixOperatorExpr.`operator`.tokenKind {
        case .reserved(.add): .plus
        case .reserved(.sub): .minus
        case .reserved(.mul): .reference
        case .reserved(.and): .address
        case .keyword(.sizeof): .sizeof
        default: fatalError()
        }

        return PrefixOperatorExprNode(operator: operatorKind, expression: generate(prefixOperatorExpr.expression), sourceRange: prefixOperatorExpr.sourceRange)
    }

    func generate(_ infixOperatorExpr: InfixOperatorExprSyntax) -> InfixOperatorExprNode {
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
            left: generate(infixOperatorExpr.left),
            operator: operatorKind,
            right: generate(infixOperatorExpr.right),
            sourceRange: infixOperatorExpr.sourceRange
        )
    }

    func generate(_ functionCallExpr: FunctionCallExprSyntax) -> FunctionCallExprNode {
        FunctionCallExprNode(
            identifier: generate(functionCallExpr.identifier),
            arguments: functionCallExpr.arguments.map { generate($0) },
            sourceRange: functionCallExpr.sourceRange
        )
    }

    func generate(_ subscriptCallExpr: SubscriptCallExprSyntax) -> SubscriptCallExprNode {
        SubscriptCallExprNode(
            identifier: generate(subscriptCallExpr.identifier),
            argument: generate(subscriptCallExpr.argument),
            sourceRange: subscriptCallExpr.sourceRange
        )
    }

    func generate(_ initListExpr: InitListExprSyntax) -> InitListExprNode {
        InitListExprNode(
            expressions: initListExpr.exprListItemSyntaxs.map { generate($0) },
            sourceRange: initListExpr.sourceRange
        )
    }

    func generate(_ tupleExpr: TupleExprSyntax) -> TupleExprNode {
        TupleExprNode(
            expression: generate(tupleExpr.expression),
            sourceRange: tupleExpr.sourceRange
        )
    }

    func generate(_ ifStatement: IfStatementSyntax) -> IfStatementNode {
        IfStatementNode(
            condition: generate(ifStatement.condition),
            trueBody: generate(ifStatement.trueBody),
            falseBody: ifStatement.falseBody.map { generate($0) },
            sourceRange: ifStatement.sourceRange
        )
    }

    func generate(_ whileStatement: WhileStatementSyntax) -> WhileStatementNode {
        WhileStatementNode(
            condition: generate(whileStatement.condition),
            body: generate(whileStatement.body),
            sourceRange: whileStatement.sourceRange
        )
    }

    func generate(_ forStatement: ForStatementSyntax) -> ForStatementNode {
        ForStatementNode(
            pre: forStatement.pre.map { generate($0) },
            condition: forStatement.condition.map { generate($0) },
            post: forStatement.post.map { generate($0) },
            body: generate(forStatement.body), 
            sourceRange: forStatement.sourceRange
        )
    }

    func generate(_ returnStatement: ReturnStatementSyntax) -> ReturnStatementNode {
        ReturnStatementNode(
            expression: generate(returnStatement.expression),
            sourceRange: returnStatement.sourceRange
        )
    }

    func generate(_ blockStatement: BlockStatementSyntax) -> BlockStatementNode {
        BlockStatementNode(
            items: blockStatement.items.map { generate($0) },
            sourceRange: blockStatement.sourceRange
        )
    }

    func generate(_ functionDecl: FunctionDeclSyntax) -> FunctionDeclNode {
        FunctionDeclNode(
            returnType: generate(functionDecl.returnType),
            functionName: functionDecl.functionName.text,
            parameters: functionDecl.parameters.map { generate($0) },
            block: generate(functionDecl.block),
            sourceRange: functionDecl.sourceRange
        )
    }

    func generate(_ functionParameter: FunctionParameterSyntax) -> FunctionParameterNode {
        FunctionParameterNode(
            type: generate(functionParameter.type),
            identifierName: functionParameter.identifier.text,
            sourceRange: functionParameter.sourceRange
        )
    }

    func generate(_ variableDecl: VariableDeclSyntax) -> VariableDeclNode {
        VariableDeclNode(
            type: generate(variableDecl.type),
            identifierName: variableDecl.identifier.text,
            initializerExpr: variableDecl.initializerExpr.map { generate($0) },
            sourceRange: variableDecl.sourceRange
        )
    }

    func generate(_ syntax: any SyntaxProtocol) -> any NodeProtocol {
        switch syntax.kind {
        case .token:
            fatalError()

        case .integerLiteral:
            return generate(syntax.casted(IntegerLiteralSyntax.self))

        case .declReference:
            return generate(syntax.casted(DeclReferenceSyntax.self))

        case .stringLiteral:
            return generate(syntax.casted(StringLiteralSyntax.self))

        case .type:
            return generate(syntax.casted(TypeSyntax.self))

        case .pointerType:
            return generate(syntax.casted(PointerTypeSyntax.self))

        case .arrayType:
            return generate(syntax.casted(ArrayTypeSyntax.self))

        case .prefixOperatorExpr:
            return generate(syntax.casted(PrefixOperatorExprSyntax.self))

        case .infixOperatorExpr:
            return generate(syntax.casted(InfixOperatorExprSyntax.self))

        case .functionCallExpr:
            return generate(syntax.casted(FunctionCallExprSyntax.self))

        case .subscriptCallExpr:
            return generate(syntax.casted(SubscriptCallExprSyntax.self))

        case .initListExpr:
            return generate(syntax.casted(InitListExprSyntax.self))

        case .exprListItem:
            // ExprListItem is removed on AST
            return generate(syntax.casted(ExprListItemSyntax.self).expression)

        case .tupleExpr:
            return generate(syntax.casted(TupleExprSyntax.self))

        case .ifStatement:
            return generate(syntax.casted(IfStatementSyntax.self))

        case .whileStatement:
            return generate(syntax.casted(WhileStatementSyntax.self))

        case .forStatement:
            return generate(syntax.casted(ForStatementSyntax.self))

        case .returnStatement:
            return generate(syntax.casted(ReturnStatementSyntax.self))

        case .blockStatement:
            return generate(syntax.casted(BlockStatementSyntax.self))

        case .blockItem:
            // BlockItem is removed on AST
            return generate(syntax.casted(BlockItemSyntax.self).item)

        case .functionDecl:
            return generate(syntax.casted(FunctionDeclSyntax.self))

        case .functionParameter:
            return generate(syntax.casted(FunctionParameterSyntax.self))

        case .variableDecl:
            return generate(syntax.casted(VariableDeclSyntax.self))

        case .sourceFile:
            fatalError()
        }
    }
}
