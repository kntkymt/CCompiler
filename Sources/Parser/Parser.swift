import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(location: SourceLocation)
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
    func consumeIdentifierToken() throws -> TokenNode {
        if case .identifier = tokens[index].kind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeNumberToken() throws -> TokenNode {
        if case .number = tokens[index].kind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeStringLiteralToken() throws -> TokenNode {
        if case .stringLiteral = tokens[index].kind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeReservedToken(_ reservedKind: TokenKind.ReservedKind) throws -> TokenNode {
        if case .reserved(let kind) = tokens[index].kind, kind == reservedKind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeKeywordToken(_ keywordKind: TokenKind.KeywordKind) throws -> TokenNode {
        if case .keyword(let kind) = tokens[index].kind, kind == keywordKind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeTypeToken() throws -> TokenNode {
        if case .type = tokens[index].kind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    @discardableResult
    func consumeEndOfFileToken() throws -> TokenNode {
        if case .endOfFile = tokens[index].kind {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }


    // MARK: - Public

    public func parse() throws -> SourceFileNode {
        if tokens.isEmpty {
            throw ParseError.invalidSyntax(location: .startOfFile)
        }

        return try program()
    }

    // MARK: - Syntax

    // program = (functionDecl | variableDecl)*
    func program() throws -> SourceFileNode {
        var statements: [BlockItemNode] = []

        while tokens[index].kind != .endOfFile {

            let type = try type()
            let identifier = try consumeIdentifierToken()

            // functionDecl = type ident "(" functionParameters? ")" block
            if case .reserved(.parenthesisLeft) = tokens[index].kind {
                let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

                var parameters: [FunctionParameterNode] = []
                if case .type = tokens[index].kind {
                    parameters = try functionParameters()
                }

                let parenthesisRight = try consumeReservedToken(.parenthesisRight)

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
                statements.append(BlockItemNode(item: variable, semicolon: try consumeReservedToken(.semicolon)))
            }
        }

        let endOfFile = try consumeEndOfFileToken()
        return SourceFileNode(statements: statements, endOfFile: endOfFile)
    }

    // functionParameters = functionParameter+
    func functionParameters() throws -> [FunctionParameterNode] {
        var results: [FunctionParameterNode] = []

        results.append(try functionParameter())

        while tokens[index].kind != .endOfFile {
            if case .reserved(.parenthesisRight) = tokens[index].kind {
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

        if case .reserved(.squareLeft) = tokens[index].kind {
            type = ArrayTypeNode(
                elementType: type,
                squareLeft: try consumeReservedToken(.squareLeft),
                arraySize: try consumeNumberToken(),
                squareRight: try consumeReservedToken(.squareRight)
            )
        }

        if case .reserved(.comma) = tokens[index].kind {
            return FunctionParameterNode(
                type: type,
                identifier: identifier,
                comma: try consumeReservedToken(.comma)
            )
        } else {
            return FunctionParameterNode(
                type: type,
                identifier: identifier
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
        switch tokens[index].kind {
        case .reserved(.braceLeft):
            return BlockItemNode(item: try block())

        case .type:
            return BlockItemNode(item: try variableDecl(), semicolon: try consumeReservedToken(.semicolon))

        case .keyword(.if):
            let ifToken = try consumeKeywordToken(.if)

            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            let parenthesisRight = try consumeReservedToken(.parenthesisRight)

            let trueStatement = try stmt()

            var elseToken: TokenNode?
            var falseStatement: BlockItemNode?
            if case .keyword(.else) = tokens[index].kind {
                elseToken = try consumeKeywordToken(.else)
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
            let token = try consumeKeywordToken(.while)

            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            let parenthesisRight = try consumeReservedToken(.parenthesisRight)

            let whileStatement = WhileStatementNode(
                while: token,
                parenthesisLeft: parenthesisLeft,
                condition: condition,
                parenthesisRight: parenthesisRight,
                body: try stmt()
            )
            return BlockItemNode(item: whileStatement)

        case .keyword(.for):
            let forToken = try consumeKeywordToken(.for)
            let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

            var preExpr: (any NodeProtocol)?
            let firstSemicolon: TokenNode
            if case .reserved(.semicolon) = tokens[index].kind {
                firstSemicolon = try consumeReservedToken(.semicolon)
            } else {
                preExpr = try expr()
                firstSemicolon = try consumeReservedToken(.semicolon)
            }

            var condition: (any NodeProtocol)?
            let secondSemicolon: TokenNode
            if case .reserved(.semicolon) = tokens[index].kind {
                secondSemicolon = try consumeReservedToken(.semicolon)
            } else {
                condition = try expr()
                secondSemicolon = try consumeReservedToken(.semicolon)
            }

            var postExpr: (any NodeProtocol)?
            let parenthesisRight: TokenNode
            if case .reserved(.parenthesisRight) = tokens[index].kind {
                parenthesisRight = try consumeReservedToken(.parenthesisRight)
            } else {
                postExpr = try expr()
                parenthesisRight = try consumeReservedToken(.parenthesisRight)
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
            let token = try consumeKeywordToken(.return)
            let left = try expr()

            let returnStatement = ReturnStatementNode(return: token, expression: left)
            return BlockItemNode(
                item: returnStatement,
                semicolon: try consumeReservedToken(.semicolon)
            )

        default:
            return BlockItemNode(
                item: try expr(),
                semicolon: try consumeReservedToken(.semicolon)
            )
        }
    }

    // block = "{" stmt* "}"
    func block() throws -> BlockStatementNode {
        let braceLeft = try consumeReservedToken(.braceLeft)

        var items: [BlockItemNode] = []
        while tokens[index].kind != .endOfFile {
            if case .reserved(.braceRight) = tokens[index].kind {
                break
            }

            items.append(try stmt())
        }

        let braceRight = try consumeReservedToken(.braceRight)

        return BlockStatementNode(
            braceLeft: braceLeft,
            items: items,
            braceRight: braceRight
        )
    }

    // variableDecl = type identifier ("[" num "]")? ("=" (expr | "{" exprList "}" | stringLiteral)? ";"
    func variableDecl(variableType: (any TypeNodeProtocol)? = nil, identifier: TokenNode? = nil) throws -> VariableDeclNode {
        var type = if let variableType { variableType } else { try type() }
        let identifier = if let identifier { identifier } else { try consumeIdentifierToken() }

        if case .reserved(.squareLeft) = tokens[index].kind {
            type = ArrayTypeNode(
                elementType: type,
                squareLeft: try consumeReservedToken(.squareLeft),
                arraySize: try consumeNumberToken(),
                squareRight: try consumeReservedToken(.squareRight)
            )
        }

        if case .reserved(.assign) = tokens[index].kind {
            let initializer = try consumeReservedToken(.assign)

            switch tokens[index].kind {
            case .reserved(.braceLeft):
                return VariableDeclNode(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: ArrayExpressionNode(
                        braceLeft: try consumeReservedToken(.braceLeft),
                        exprListNodes: try exprList(),
                        braceRight: try consumeReservedToken(.braceRight)
                    )
                )

            case .stringLiteral:
                return VariableDeclNode(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: StringLiteralNode(literal: try consumeStringLiteralToken())
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
        var node: any TypeNodeProtocol = TypeNode(type: try consumeTypeToken())

        while tokens[index].kind != .endOfFile {
            if case .reserved(.mul) = tokens[index].kind {
                let mulToken = try consumeReservedToken(.mul)
                node = PointerTypeNode(referenceType: node, pointer: mulToken)
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

        if case .reserved(.assign) = tokens[index].kind {
            let token = try consumeReservedToken(.assign)
            let rightNode = try assign()

            node = InfixOperatorExpressionNode(
                left: node, 
                operator: AssignNode(equal: token),
                right: rightNode
            )
        }

        return node
    }

    // equality = relational ("==" relational | "!=" relational)*
    func equality() throws -> any NodeProtocol {
        var node = try relational()

        while tokens[index].kind != .endOfFile {
            switch tokens[index].kind {
            case .reserved(.equal):
                let token = try consumeReservedToken(.equal)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
                    right: rightNode
                )

            case .reserved(.notEqual):
                let token = try consumeReservedToken(.notEqual)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
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

        while tokens[index].kind != .endOfFile {
            switch tokens[index].kind {
            case .reserved(.lessThan):
                let token = try consumeReservedToken(.lessThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
                    right: rightNode
                )

            case .reserved(.lessThanOrEqual):
                let token = try consumeReservedToken(.lessThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
                    right: rightNode
                )

            case .reserved(.greaterThan):
                let token = try consumeReservedToken(.greaterThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
                    right: rightNode
                )

            case .reserved(.greaterThanOrEqual):
                let token = try consumeReservedToken(.greaterThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: token),
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

        while tokens[index].kind != .endOfFile {
            switch tokens[index].kind {
            case .reserved(.add):
                let addToken = try consumeReservedToken(.add)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: addToken),
                    right: rightNode
                )

            case .reserved(.sub):
                let subToken = try consumeReservedToken(.sub)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: subToken),
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

        while tokens[index].kind != .endOfFile {
            switch tokens[index].kind {
            case .reserved(.mul):
                let mulToken = try consumeReservedToken(.mul)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: mulToken),
                    right: rightNode
                )

            case .reserved(.div):
                let divToken = try consumeReservedToken(.div)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    left: node, 
                    operator: BinaryOperatorNode(operator: divToken),
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
        switch tokens[index].kind {
        case .keyword(.sizeof):
            return PrefixOperatorExpressionNode(
                operator: try consumeKeywordToken(.sizeof),
                expression: try unary()
            )

        case .reserved(.add):
            return PrefixOperatorExpressionNode(
                operator: try consumeReservedToken(.add),
                expression: try primary()
            )

        case .reserved(.sub):
            return PrefixOperatorExpressionNode(
                operator: try consumeReservedToken(.sub),
                expression: try primary()
            )

        case .reserved(.mul):
            let mulToken = try consumeReservedToken(.mul)
            let right = try unary()

            return PrefixOperatorExpressionNode(
                operator: mulToken,
                expression: right
            )

        case .reserved(.and):
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
        switch tokens[index].kind {
        case .reserved(.parenthesisLeft):
            return TupleExpressionNode(
                parenthesisLeft: try consumeReservedToken(.parenthesisLeft),
                expression: try expr(),
                parenthesisRight: try consumeReservedToken(.parenthesisRight)
            )

        case .number:
            let numberToken = try consumeNumberToken()
            let numberNode = IntegerLiteralNode(literal: numberToken)

            return numberNode

        case .stringLiteral:
            let stringToken = try consumeStringLiteralToken()
            let stringLiteralNode = StringLiteralNode(literal: stringToken)

            return stringLiteralNode

        case .identifier:
            let identifierToken = try consumeIdentifierToken()

            if case .reserved(.parenthesisLeft) = tokens[index].kind {
                let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

                var argments: [ExpressionListItemNode] = []
                if tokens[index].kind != .endOfFile {
                    if case .reserved(.parenthesisRight) = tokens[index].kind {

                    } else {
                        argments = try exprList()
                    }
                }

                let parenthesisRight = try consumeReservedToken(.parenthesisRight)

                return FunctionCallExpressionNode(
                    identifier: identifierToken,
                    parenthesisLeft: parenthesisLeft,
                    arguments: argments,
                    parenthesisRight: parenthesisRight
                )
            } else if case .reserved(.squareLeft) = tokens[index].kind {
                return SubscriptCallExpressionNode(
                    identifier: IdentifierNode(baseName: identifierToken),
                    squareLeft: try consumeReservedToken(.squareLeft),
                    argument: try expr(),
                    squareRight: try consumeReservedToken(.squareRight)
                )
            } else {
                return IdentifierNode(baseName: identifierToken)
            }

        default:
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    // exprList = exprList+
    func exprList() throws -> [ExpressionListItemNode] {
        var results: [ExpressionListItemNode] = []
        results.append(try exprListItem())

        while tokens[index].kind != .endOfFile {
            if case .reserved = tokens[index].kind {
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
        if case .reserved(.comma) = tokens[index].kind {
            return ExpressionListItemNode(
                expression: expr,
                comma: try consumeReservedToken(.comma)
            )
        } else {
            return ExpressionListItemNode(expression: expr)
        }
    }
}
