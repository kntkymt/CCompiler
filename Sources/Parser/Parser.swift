import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(location: SourceLocation)
}

public final class Parser {

    // MARK: - Property

    var index = 0
    var tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Public

    public func parse() throws -> SourceFileNode {
        try program()
    }

    // MARK: - Syntax

    // program = (functionDecl | variableDecl)*
    func program() throws -> SourceFileNode {
        var statements: [BlockItemNode] = []

        while !at(.endOfFile) {

            let type = try type()
            let identifier = try consume(.identifier)

            // functionDecl = type ident "(" functionParameters? ")" block
            if let parenthesisLeft = consume(if: .reserved(.parenthesisLeft)) {
                var parameters: [FunctionParameterNode] = []
                if at(.type) {
                    parameters = try functionParameters()
                }

                let parenthesisRight = try consume(.reserved(.parenthesisRight))

                let function = FunctionDeclNode(
                    returnType: type,
                    functionName: identifier,
                    parenthesisLeft: parenthesisLeft,
                    parameters: parameters,
                    parenthesisRight: parenthesisRight,
                    block: try block()
                )
                statements.append(BlockItemNode(item: function))
            } else {
                let variable = try variableDecl(variableType: type, identifier: identifier)
                statements.append(BlockItemNode(item: variable, semicolon: try consume(.reserved(.semicolon))))
            }
        }

        let endOfFile = try consume(.endOfFile)
        return SourceFileNode(statements: statements, endOfFile: endOfFile)
    }

    // functionParameters = functionParameter+
    func functionParameters() throws -> [FunctionParameterNode] {
        var results: [FunctionParameterNode] = []

        repeat {
            results.append(try functionParameter())
        } while !at(.reserved(.parenthesisRight))

        return results
    }

    // functionParameter = type identifier ","?
    func functionParameter() throws -> FunctionParameterNode {
        var type = try type()
        let identifier = try consume(.identifier)

        if at(.reserved(.squareLeft)) {
            type = ArrayTypeNode(
                elementType: type,
                squareLeft: try consume(.reserved(.squareLeft)),
                arraySize: try consume(.integerLiteral),
                squareRight: try consume(.reserved(.squareRight))
            )
        }

        return FunctionParameterNode(
            type: type,
            identifier: identifier,
            comma: consume(if: .reserved(.comma))
        )
    }

    // stmt    = expr ";"
    //         | block
    //         | variableDecl
    //         | "if" "(" expr ")" stmt ("else" stmt)?
    //         | "while" "(" expr ")" stmt
    //         | "for" "(" expr? ";" expr? ";" expr? ")" stmt
    //         | "return" expr ";"
    func stmt() throws -> BlockItemNode {
        switch tokens[index].kind {
        case .reserved(.braceLeft):
            return BlockItemNode(item: try block())

        case .type:
            return BlockItemNode(item: try variableDecl(), semicolon: try consume(.reserved(.semicolon)))

        case .keyword(.if):
            let ifToken = try consume(.keyword(.if))

            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))
            let condition = try expr()
            let parenthesisRight = try consume(.reserved(.parenthesisRight))

            let trueStatement = try stmt()

            var elseToken: TokenNode?
            var falseStatement: BlockItemNode?
            if at(.keyword(.else)) {
                elseToken = try consume(.keyword(.else))
                falseStatement = try stmt()
            }

            let ifStatement = IfStatementNode(
                if: ifToken,
                parenthesisLeft: parenthesisLeft,
                condition: condition,
                parenthesisRight: parenthesisRight,
                trueBody: trueStatement,
                else: elseToken,
                falseBody: falseStatement
            )
            return BlockItemNode(item: ifStatement)

        case .keyword(.while):
            let token = try consume(.keyword(.while))

            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))
            let condition = try expr()
            let parenthesisRight = try consume(.reserved(.parenthesisRight))

            let whileStatement = WhileStatementNode(
                while: token,
                parenthesisLeft: parenthesisLeft,
                condition: condition,
                parenthesisRight: parenthesisRight,
                body: try stmt()
            )
            return BlockItemNode(item: whileStatement)

        case .keyword(.for):
            let forToken = try consume(.keyword(.for))
            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))

            var preExpr: (any NodeProtocol)?
            let firstSemicolon: TokenNode
            if let semicolon = consume(if: .reserved(.semicolon)) {
                firstSemicolon = semicolon
            } else {
                preExpr = try expr()
                firstSemicolon = try consume(.reserved(.semicolon))
            }

            var condition: (any NodeProtocol)?
            let secondSemicolon: TokenNode
            if let semicolon = consume(if: .reserved(.semicolon)) {
                secondSemicolon = semicolon
            } else {
                condition = try expr()
                secondSemicolon = try consume(.reserved(.semicolon))
            }

            var postExpr: (any NodeProtocol)?
            let parenthesisRight: TokenNode
            if let paren = consume(if: .reserved(.parenthesisRight)) {
                parenthesisRight = paren
            } else {
                postExpr = try expr()
                parenthesisRight = try consume(.reserved(.parenthesisRight))
            }

            let forStatement = ForStatementNode(
                for: forToken,
                parenthesisLeft: parenthesisLeft,
                pre: preExpr,
                firstSemicolon: firstSemicolon,
                condition: condition,
                secondSemicolon: secondSemicolon,
                post: postExpr,
                parenthesisRight: parenthesisRight,
                body: try stmt()
            )
            return BlockItemNode(item: forStatement)

        case .keyword(.return):
            let token = try consume(.keyword(.return))
            let left = try expr()

            let returnStatement = ReturnStatementNode(return: token, expression: left)
            return BlockItemNode(
                item: returnStatement,
                semicolon: try consume(.reserved(.semicolon))
            )

        default:
            return BlockItemNode(
                item: try expr(),
                semicolon: try consume(.reserved(.semicolon))
            )
        }
    }

    // block = "{" stmt* "}"
    func block() throws -> BlockStatementNode {
        let braceLeft = try consume(.reserved(.braceLeft))

        var items: [BlockItemNode] = []
        while !at(.reserved(.braceRight)) {
            items.append(try stmt())
        }

        let braceRight = try consume(.reserved(.braceRight))

        return BlockStatementNode(
            braceLeft: braceLeft,
            items: items,
            braceRight: braceRight
        )
    }

    // variableDecl = type identifier ("[" num "]")? ("=" (expr | "{" exprList "}" | stringLiteral)? ";"
    func variableDecl(variableType: (any TypeNodeProtocol)? = nil, identifier: TokenNode? = nil) throws -> VariableDeclNode {
        var type = if let variableType { variableType } else { try type() }
        let identifier = if let identifier { identifier } else { try consume(.identifier) }

        if at(.reserved(.squareLeft)) {
            type = ArrayTypeNode(
                elementType: type,
                squareLeft: try consume(.reserved(.squareLeft)),
                arraySize: try consume(.integerLiteral),
                squareRight: try consume(.reserved(.squareRight))
            )
        }

        if let initializer = consume(if: .reserved(.assign)) {
            switch tokens[index].kind {
            case .reserved(.braceLeft):
                return VariableDeclNode(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: ArrayExpressionNode(
                        braceLeft: try consume(.reserved(.braceLeft)),
                        exprListNodes: try exprList(),
                        braceRight: try consume(.reserved(.braceRight))
                    )
                )

            case .stringLiteral:
                return VariableDeclNode(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: StringLiteralNode(literal: try consume(.stringLiteral))
                )

            default:
                return VariableDeclNode(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: try expr()
                )
            }
        }

        return VariableDeclNode(
            type: type,
            identifier: identifier
        )
    }

    // type = typeIdentifier "*"*
    func type() throws -> any TypeNodeProtocol {
        var node: any TypeNodeProtocol = TypeNode(type: try consume(.type))

        while let mulToken = consume(if: .reserved(.mul)) {
            node = PointerTypeNode(referenceType: node, pointer: mulToken)
        }

        return node
    }

    // expr = assign
    func expr() throws -> any NodeProtocol {
        try assign()
    }

    // assign = equality ("=" assign)?
    func assign() throws -> any NodeProtocol {
        var node = try equality()

        if let token = consume(if: .reserved(.assign)) {
            let rightNode = try assign()

            node = InfixOperatorExpressionNode(
                left: node, 
                operator: AssignNode(equal: token),
                right: rightNode
            )
        }

        return node
    }

    // equality = relational (("==" | "!=") relational)*
    func equality() throws -> any NodeProtocol {
        var node = try relational()

        while let equalityToken = consume(if: .reserved(.equal), .reserved(.notEqual)) {
            node = InfixOperatorExpressionNode(
                left: node,
                operator: BinaryOperatorNode(operator: equalityToken),
                right: try relational()
            )
        }

        return node
    }

    // relational = add (("<" | "<=" | ">" | ">=") add)*
    func relational() throws -> any NodeProtocol {
        var node = try add()

        while let relationalToken = consume(if: .reserved(.lessThan), .reserved(.lessThanOrEqual), .reserved(.greaterThan), .reserved(.greaterThanOrEqual)) {
            node = InfixOperatorExpressionNode(
                left: node,
                operator: BinaryOperatorNode(operator: relationalToken),
                right: try add()
            )
        }

        return node
    }

    // add = mul (("+" | "-") mul)*
    func add() throws -> any NodeProtocol {
        var node = try mul()

        while let addOrSub = consume(if: .reserved(.add), .reserved(.sub)) {
            node = InfixOperatorExpressionNode(
                left: node,
                operator: BinaryOperatorNode(operator: addOrSub),
                right: try mul()
            )
        }

        return node
    }

    // mul = unary (("*" |"/") unary)*
    func mul() throws -> any NodeProtocol {
        var node = try unary()

        while let mulOrDivToken = consume(if: .reserved(.mul), .reserved(.div)) {
            node = InfixOperatorExpressionNode(
                left: node,
                operator: BinaryOperatorNode(operator: mulOrDivToken),
                right: try unary()
            )
        }

        return node
    }

    // unary = | ("+" | "-") primary
    //         | ("sizeof" | "*" | "&") unary
    //         | primary
    func unary() throws -> any NodeProtocol {
        if let addOrSub = consume(if: .reserved(.add), .reserved(.sub)) {
            return PrefixOperatorExpressionNode(
                operator: addOrSub,
                expression: try primary()
            )
        } else if let sizeofOrMulOrAnd = consume(if: .keyword(.sizeof), .reserved(.mul), .reserved(.and)) {
            return PrefixOperatorExpressionNode(
                operator: sizeofOrMulOrAnd,
                expression: try unary()
            )
        } else {
            return try primary()
        }
    }

    // primary = num
    //         | stringLiteral
    //         | ident ( ("( exprList? )") | ("[" expr "]") )?
    //         | "(" expr ")"
    func primary() throws -> any NodeProtocol {
        switch tokens[index].kind {
        case .reserved(.parenthesisLeft):
            return TupleExpressionNode(
                parenthesisLeft: try consume(.reserved(.parenthesisLeft)),
                expression: try expr(),
                parenthesisRight: try consume(.reserved(.parenthesisRight))
            )

        case .integerLiteral:
            return IntegerLiteralNode(literal: try consume(.integerLiteral))

        case .stringLiteral:
            return StringLiteralNode(literal: try consume(.stringLiteral))

        case .identifier:
            let identifierToken = try consume(.identifier)

            if let parenthesisLeft = consume(if: .reserved(.parenthesisLeft)) {
                var argments: [ExpressionListItemNode] = []
                if !at(.reserved(.parenthesisRight)) {
                    argments = try exprList()
                }

                let parenthesisRight = try consume(.reserved(.parenthesisRight))

                return FunctionCallExpressionNode(
                    identifier: identifierToken,
                    parenthesisLeft: parenthesisLeft,
                    arguments: argments,
                    parenthesisRight: parenthesisRight
                )
            } else if at(.reserved(.squareLeft)) {
                return SubscriptCallExpressionNode(
                    identifier: IdentifierNode(baseName: identifierToken),
                    squareLeft: try consume(.reserved(.squareLeft)),
                    argument: try expr(),
                    squareRight: try consume(.reserved(.squareRight))
                )
            } else {
                return IdentifierNode(baseName: identifierToken)
            }

        default:
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    // exprList = (expr ","?)+
    func exprList() throws -> [ExpressionListItemNode] {
        var results: [ExpressionListItemNode] = []

        repeat {
            results.append(
                ExpressionListItemNode(
                    expression: try expr(),
                    comma: consume(if: .reserved(.comma))
                )
            )
        } while !(at(.reserved(.parenthesisRight)) || at(.reserved(.braceRight)))

        return results
    }
}
