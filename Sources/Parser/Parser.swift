import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(index: Int)
}

public final class Parser {

    // MARK: - Property

    private var index = 0
    private var tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Util

    @discardableResult
    func consumeIdentifierToken() throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .identifier = tokens[index] {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    @discardableResult
    func consumeNumberToken() throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .number = tokens[index] {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    @discardableResult
    func consumeStringLiteralToken() throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .stringLiteral = tokens[index] {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    @discardableResult
    func consumeReservedToken(_ reservedKind: Token.ReservedKind) throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .reserved(let kind, _) = tokens[index], kind == reservedKind {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    @discardableResult
    func consumeKeywordToken(_ keywordKind: Token.KeywordKind) throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .keyword(let kind, _) = tokens[index], kind == keywordKind {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    @discardableResult
    func consumeTypeToken() throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .type = tokens[index] {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }


    // MARK: - Public

    public func parse() throws -> SourceFileNode {
        if tokens.isEmpty {
            throw ParseError.invalidSyntax(index: 0)
        }

        return try program()
    }

    // MARK: - Syntax

    // program = (functionDecl | variableDecl)*
    func program() throws -> SourceFileNode {
        var statements: [BlockItemNode] = []

        while index < tokens.count {

            let type = try type()
            let identifier = try consumeIdentifierToken()

            // functionDecl = type ident "(" functionParameters? ")" block
            if index < tokens.count, case .reserved(.parenthesisLeft, _) = tokens[index] {
                let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

                var parameters: [FunctionParameterNode] = []
                if index < tokens.count, case .type = tokens[index] {
                    parameters = try functionParameters()
                }

                let parenthesisRight = try consumeReservedToken(.parenthesisRight)

                let function = FunctionDeclNode(
                    returnTypeNode: type,
                    functionNameToken: identifier,
                    parenthesisLeftToken: parenthesisLeft,
                    parameterNodes: parameters,
                    parenthesisRightToken: parenthesisRight,
                    block: try block()
                )
                statements.append(BlockItemNode(item: function))
            } else {
                let variable = try variableDecl(variableType: type, identifier: identifier)
                statements.append(BlockItemNode(item: variable, semicolonToken: try consumeReservedToken(.semicolon)))
            }
        }

        return SourceFileNode(statements: statements)
    }

    // functionParameters = functionParameter+
    func functionParameters() throws -> [FunctionParameterNode] {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        var results: [FunctionParameterNode] = []

        results.append(try functionParameter())

        while index < tokens.count {
            if case .reserved(.parenthesisRight, _) = tokens[index] {
                break
            }

            results.append(try functionParameter())
        }

        return results
    }

    // functionParameter = type identifier ","?
    func functionParameter() throws -> FunctionParameterNode {
        var type = try type()
        let identifier = try consumeIdentifierToken()

        if index < tokens.count, case .reserved(.squareLeft, _) = tokens[index] {
            type = ArrayTypeNode(
                elementType: type,
                squareLeftToken: try consumeReservedToken(.squareLeft),
                arraySizeToken: try consumeNumberToken(),
                squareRightToken: try consumeReservedToken(.squareRight)
            )
        }

        if index < tokens.count, case .reserved(.comma, _) = tokens[index] {
            return FunctionParameterNode(
                type: type,
                identifierToken: identifier,
                commaToken: try consumeReservedToken(.comma)
            )
        } else {
            return FunctionParameterNode(
                type: type,
                identifierToken: identifier
            )
        }
    }

    // stmt    = expr ";"
    //         | block
    //         | variableDecl
    //         | "if" "(" expr ")" stmt ("else" stmt)?
    //         | "while" "(" expr ")" stmt
    //         | "for" "(" expr? ";" expr? ";" expr? ")" stmt
    //         | "return" expr ";"
    func stmt() throws -> BlockItemNode {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        switch tokens[index] {
        case .reserved(.braceLeft, _):
            return BlockItemNode(item: try block())

        case .type:
            return BlockItemNode(item: try variableDecl(), semicolonToken: try consumeReservedToken(.semicolon))

        case .keyword(.if, _):
            let ifToken = try consumeKeywordToken(.if)

            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            let parenthesisRight = try consumeReservedToken(.parenthesisRight)

            let trueStatement = try stmt()

            var elseToken: Token?
            var falseStatement: BlockItemNode?
            if index < tokens.count, case .keyword(.else, _) = tokens[index] {
                elseToken = try consumeKeywordToken(.else)
                falseStatement = try stmt()
            }

            let ifStatement = IfStatementNode(
                ifToken: ifToken,
                parenthesisLeftToken: parenthesisLeft,
                condition: condition,
                parenthesisRightToken: parenthesisRight,
                trueBody: trueStatement,
                elseToken: elseToken,
                falseBody: falseStatement
            )
            return BlockItemNode(item: ifStatement)

        case .keyword(.while, _):
            let token = try consumeKeywordToken(.while)

            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            let parenthesisRight = try consumeReservedToken(.parenthesisRight)

            let whileStatement = WhileStatementNode(
                whileToken: token,
                parenthesisLeftToken: parenthesisLeft,
                condition: condition,
                parenthesisRightToken: parenthesisRight,
                body: try stmt()
            )
            return BlockItemNode(item: whileStatement)

        case .keyword(.for, _):
            let forToken = try consumeKeywordToken(.for)
            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

            var preExpr: (any NodeProtocol)?
            let firstSemicolon: Token
            if case .reserved(.semicolon, _) = tokens[index] {
                firstSemicolon = try consumeReservedToken(.semicolon)
            } else {
                preExpr = try expr()
                firstSemicolon = try consumeReservedToken(.semicolon)
            }

            var condition: (any NodeProtocol)?
            let secondSemicolon: Token
            if case .reserved(.semicolon, _) = tokens[index] {
                secondSemicolon = try consumeReservedToken(.semicolon)
            } else {
                condition = try expr()
                secondSemicolon = try consumeReservedToken(.semicolon)
            }

            var postExpr: (any NodeProtocol)?
            let parenthesisRight: Token
            if case .reserved(.parenthesisRight, _) = tokens[index] {
                parenthesisRight = try consumeReservedToken(.parenthesisRight)
            } else {
                postExpr = try expr()
                parenthesisRight = try consumeReservedToken(.parenthesisRight)
            }

            let forStatement = ForStatementNode(
                forToken: forToken,
                parenthesisLeftToken: parenthesisLeft,
                pre: preExpr,
                firstSemicolonToken: firstSemicolon,
                condition: condition,
                secondSemicolonToken: secondSemicolon,
                post: postExpr,
                parenthesisRightToken: parenthesisRight,
                body: try stmt()
            )
            return BlockItemNode(item: forStatement)

        case .keyword(.return, _):
            let token = try consumeKeywordToken(.return)
            let left = try expr()

            let returnStatement = ReturnStatementNode(returnToken: token, expression: left)
            return BlockItemNode(
                item: returnStatement,
                semicolonToken: try consumeReservedToken(.semicolon)
            )

        default:
            return BlockItemNode(
                item: try expr(),
                semicolonToken: try consumeReservedToken(.semicolon)
            )
        }
    }

    // block = "{" stmt* "}"
    func block() throws -> BlockStatementNode {
        let braceLeft = try consumeReservedToken(.braceLeft)

        var items: [BlockItemNode] = []
        while index < tokens.count {
            if index < tokens.count, case .reserved(.braceRight, _) = tokens[index] {
                break
            }

            items.append(try stmt())
        }

        let braceRight = try consumeReservedToken(.braceRight)

        return BlockStatementNode(
            braceLeftToken: braceLeft,
            items: items,
            braceRightToken: braceRight
        )
    }

    // variableDecl = type identifier ("[" num "]")? ("=" (expr | "{" exprList "}" | stringLiteral)? ";"
    func variableDecl(variableType: (any TypeNodeProtocol)? = nil, identifier: Token? = nil) throws -> VariableDeclNode {
        var type = if let variableType { variableType } else { try type() }
        let identifier = if let identifier { identifier } else { try consumeIdentifierToken() }

        if index < tokens.count, case .reserved(.squareLeft, _) = tokens[index] {
            type = ArrayTypeNode(
                elementType: type,
                squareLeftToken: try consumeReservedToken(.squareLeft),
                arraySizeToken: try consumeNumberToken(),
                squareRightToken: try consumeReservedToken(.squareRight)
            )
        }

        if index < tokens.count, case .reserved(.assign, _) = tokens[index] {
            let initializerToken = try consumeReservedToken(.assign)

            switch tokens[index] {
            case .reserved(.braceLeft, _):
                return VariableDeclNode(
                    type: type,
                    identifierToken: identifier,
                    initializerToken: initializerToken,
                    initializerExpr: ArrayExpressionNode(
                        braceLeft: try consumeReservedToken(.braceLeft),
                        exprListNodes: try exprList(),
                        braceRight: try consumeReservedToken(.braceRight)
                    )
                )

            case .stringLiteral:
                return VariableDeclNode(
                    type: type,
                    identifierToken: identifier,
                    initializerToken: initializerToken,
                    initializerExpr: StringLiteralNode(token: try consumeStringLiteralToken())
                )

            default:
                return VariableDeclNode(
                    type: type,
                    identifierToken: identifier,
                    initializerToken: initializerToken,
                    initializerExpr: try expr()
                )
            }
        }

        return VariableDeclNode(
            type: type,
            identifierToken: identifier
        )
    }

    // type = typeIdentifier "*"*
    func type() throws -> any TypeNodeProtocol {
        var node: any TypeNodeProtocol = TypeNode(typeToken: try consumeTypeToken())

        while index < tokens.count {
            if case .reserved(.mul, _) = tokens[index] {
                let mulToken = try consumeReservedToken(.mul)
                node = PointerTypeNode(referenceType: node, pointerToken: mulToken)
            } else {
                break
            }
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

        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .reserved(.assign, _) = tokens[index] {
            let token = try consumeReservedToken(.assign)
            let rightNode = try assign()

            node = InfixOperatorExpressionNode(
                left: node, 
                operator: AssignNode(token: token),
                right: rightNode
            )
        }

        return node
    }

    // equality = relational ("==" relational | "!=" relational)*
    func equality() throws -> any NodeProtocol {
        var node = try relational()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.equal, _):
                let token = try consumeReservedToken(.equal)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            case .reserved(.notEqual, _):
                let token = try consumeReservedToken(.notEqual)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            default:
                return node
            }
        }

        return node
    }

    // relational = add ("<" add | "<=" add | ">" add | ">=" add)*
    func relational() throws -> any NodeProtocol {
        var node = try add()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.lessThan, _):
                let token = try consumeReservedToken(.lessThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            case .reserved(.lessThanOrEqual, _):
                let token = try consumeReservedToken(.lessThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            case .reserved(.greaterThan, _):
                let token = try consumeReservedToken(.greaterThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            case .reserved(.greaterThanOrEqual, _):
                let token = try consumeReservedToken(.greaterThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: token),
                    right: rightNode
                )

            default:
                return node
            }
        }

        return node
    }

    // add = mul ("+" mul | "-" mul)*
    func add() throws -> any NodeProtocol {
        var node = try mul()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.add, _):
                let addToken = try consumeReservedToken(.add)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: addToken),
                    right: rightNode
                )

            case .reserved(.sub, _):
                let subToken = try consumeReservedToken(.sub)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: subToken),
                    right: rightNode
                )

            default:
                return node
            }
        }

        return node
    }

    // mul = unary ("*" unary | "/" unary)*
    func mul() throws -> any NodeProtocol {
        var node = try unary()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.mul, _):
                let mulToken = try consumeReservedToken(.mul)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: mulToken),
                    right: rightNode
                )

            case .reserved(.div, _):
                let divToken = try consumeReservedToken(.div)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(token: divToken),
                    right: rightNode
                )

            default:
                return node
            }
        }

        return node
    }

    // unary = "sizeof" unary
    //       | ("+" | "-")? primary
    //       | ("*" | "&") unary
    func unary() throws -> any NodeProtocol {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        switch tokens[index] {
        case .keyword(.sizeof, _):
            try consumeKeywordToken(.sizeof)

            let unary = try unary()

            // FIXME: どうやって式の型を判断する？
            return IntegerLiteralNode(token: .number("8", sourceIndex: unary.sourceTokens[0].sourceIndex))

        case .reserved(.add, _):
            return PrefixOperatorExpressionNode(
                operator: try consumeReservedToken(.add),
                expression: try primary()
            )

        case .reserved(.sub, _):
            return PrefixOperatorExpressionNode(
                operator: try consumeReservedToken(.sub),
                expression: try primary()
            )

        case .reserved(.mul, _):
            let mulToken = try consumeReservedToken(.mul)
            let right = try unary()

            return PrefixOperatorExpressionNode(
                operator: mulToken,
                expression: right
            )

        case .reserved(.and, _):
            let andToken = try consumeReservedToken(.and)
            let right = try unary()

            return PrefixOperatorExpressionNode(
                operator: andToken,
                expression: right
            )

        default:
            return try primary()
        }
    }

    // primary = num
    //         | stringLiteral
    //         | ident ( ("( exprList? )") | ("[" expr "]") )?
    //         | "(" expr ")"
    func primary() throws -> any NodeProtocol {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        switch tokens[index] {
        case .reserved(.parenthesisLeft, _):
            return TupleExpressionNode(
                parenthesisLeftToken: try consumeReservedToken(.parenthesisLeft),
                expression: try expr(),
                parenthesisRightToken: try consumeReservedToken(.parenthesisRight)
            )

        case .number:
            let numberToken = try consumeNumberToken()
            let numberNode = IntegerLiteralNode(token: numberToken)

            return numberNode

        case .stringLiteral:
            let stringToken = try consumeStringLiteralToken()
            let stringLiteralNode = StringLiteralNode(token: stringToken)

            return stringLiteralNode

        case .identifier:
            let identifierToken = try consumeIdentifierToken()

            if index < tokens.count, case .reserved(.parenthesisLeft, _) = tokens[index] {
                let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

                var argments: [ExpressionListItemNode] = []
                if index < tokens.count {
                    if case .reserved(.parenthesisRight, _) = tokens[index] {

                    } else {
                        argments = try exprList()
                    }
                }

                let parenthesisRight = try consumeReservedToken(.parenthesisRight)

                return FunctionCallExpressionNode(
                    identifierToken: identifierToken,
                    parenthesisLeftToken: parenthesisLeft,
                    arguments: argments,
                    parenthesisRightToken: parenthesisRight
                )
            } else if index < tokens.count, case .reserved(.squareLeft, _) = tokens[index] {
                return SubscriptCallExpressionNode(
                    identifierNode: IdentifierNode(token: identifierToken),
                    squareLeftToken: try consumeReservedToken(.squareLeft),
                    argument: try expr(),
                    squareRightToken: try consumeReservedToken(.squareRight)
                )
            } else {
                return IdentifierNode(token: identifierToken)
            }

        default:
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    // exprList = exprList+
    func exprList() throws -> [ExpressionListItemNode] {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        var results: [ExpressionListItemNode] = []
        results.append(try exprListItem())

        while index < tokens.count {
            if case .reserved = tokens[index] {
                // ), }だったら
                break
            } else {
                results.append(try exprListItem())
            }
        }

        return results
    }

    // exprListItem = expr ","?
    func exprListItem() throws -> ExpressionListItemNode {
        let expr = try expr()
        if index < tokens.count, case .reserved(.comma, _) = tokens[index] {
            return ExpressionListItemNode(
                expression: expr,
                comma: try consumeReservedToken(.comma)
            )
        } else {
            return ExpressionListItemNode(expression: expr)
        }
    }
}
