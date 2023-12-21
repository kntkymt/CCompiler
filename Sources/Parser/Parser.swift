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

    // program = (functionDecl | variableDecl ";")*
    func program() throws -> SourceFileNode {
        var functionDecls: [FunctionDeclNode] = []
        var globalVariableDecls: [VariableDeclNode] = []

        while index < tokens.count {

            let type = try type()
            let identifier = try consumeIdentifierToken()

            // functionDecl = type ident "(" functionParameters? ")" block
            if index < tokens.count, case .reserved(.parenthesisLeft, _) = tokens[index] {
                let parenthesisLeft = try consumeReservedToken(.parenthesisLeft)

                var parameters: [VariableDeclNode] = []
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
                functionDecls.append(function)
            } else {
                let variable = try variableDecl(variableType: type, identifier: identifier)
                try consumeReservedToken(.semicolon)
                globalVariableDecls.append(variable)
            }
        }

        return SourceFileNode(functions: functionDecls, globalVariables: globalVariableDecls)
    }

    // functionParameters = variableDecl ("," variableDecl)*
    func functionParameters() throws -> [VariableDeclNode] {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        var results: [VariableDeclNode] = []

        results.append(try variableDecl())

        while index < tokens.count {
            if case .reserved(.parenthesisRight, _) = tokens[index] {
                break
            }

            try consumeReservedToken(.comma)

            results.append(try variableDecl())
        }

        return results
    }

    // stmt    = expr ";"
    //         | block
    //         | variableDecl ";"
    //         | "if" "(" expr ")" stmt ("else" stmt)?
    //         | "while" "(" expr ")" stmt
    //         | "for" "(" expr? ";" expr? ";" expr? ")" stmt
    //         | "return" expr ";"
    func stmt() throws -> any NodeProtocol {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        let startIndex = index

        switch tokens[index] {
        case .reserved(.braceLeft, _):
            return try block()

        case .type:
            let variableDecl = try variableDecl()
            try consumeReservedToken(.semicolon)

            return variableDecl

        case .keyword(.if, _):
            let ifToken = try consumeKeywordToken(.if)

            try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            try consumeReservedToken(.parenthesisRight)

            let trueStatement = try stmt()

            var elseToken: Token?
            var falseStatement: (any NodeProtocol)?
            if index < tokens.count, case .keyword(.else, _) = tokens[index] {
                elseToken = try consumeKeywordToken(.else)
                falseStatement = try stmt()
            }

            return IfStatementNode(ifToken: ifToken, condition: condition, trueBody: trueStatement, elseToken: elseToken, falseBody: falseStatement, sourceTokens: Array(tokens[startIndex..<index]))

        case .keyword(.while, _):
            let token = try consumeKeywordToken(.while)

            try consumeReservedToken(.parenthesisLeft)
            let condition = try expr()
            try consumeReservedToken(.parenthesisRight)

            return WhileStatementNode(token: token, condition: condition, body: try stmt(), sourceTokens: Array(tokens[startIndex..<index]))

        case .keyword(.for, _):
            let forToken = try consumeKeywordToken(.for)
            try consumeReservedToken(.parenthesisLeft)

            var preExpr: (any NodeProtocol)?
            if case .reserved(.semicolon, _) = tokens[index] {
                try consumeReservedToken(.semicolon)
            } else {
                preExpr = try expr()
                try consumeReservedToken(.semicolon)
            }

            var condition: (any NodeProtocol)?
            if case .reserved(.semicolon, _) = tokens[index] {
                try consumeReservedToken(.semicolon)
            } else {
                condition = try expr()
                try consumeReservedToken(.semicolon)
            }

            var postExpr: (any NodeProtocol)?
            if case .reserved(.parenthesisRight, _) = tokens[index] {
                try consumeReservedToken(.parenthesisRight)
            } else {
                postExpr = try expr()
                try consumeReservedToken(.parenthesisRight)
            }

            return ForStatementNode(token: forToken, condition: condition, pre: preExpr, post: postExpr, body: try stmt(), sourceTokens: Array(tokens[startIndex..<index]))

        case .keyword(.return, _):
            let token = try consumeKeywordToken(.return)

            let left = try expr()
            let node = ReturnStatementNode(token: token, expression: left, sourceTokens: Array(tokens[startIndex..<index]))
            try consumeReservedToken(.semicolon)

            return node

        default:
            let node = try expr()
            try consumeReservedToken(.semicolon)

            return node
        }
    }

    // block = "{" stmt* "}"
    func block() throws -> BlockStatementNode {
        let startIndex = index
        try consumeReservedToken(.braceLeft)

        var statements: [any NodeProtocol] = []
        while index < tokens.count {
            if index < tokens.count, case .reserved(.braceRight, _) = tokens[index] {
                try consumeReservedToken(.braceRight)
                break
            }

            statements.append(try stmt())
        }

        return BlockStatementNode(statements: statements, sourceTokens: Array(tokens[startIndex..<index]))
    }

    // variableDecl = type identifier ("[" num "]")?
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
        let startIndex = index
        var node = try equality()

        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .reserved(.assign, _) = tokens[index] {
            let token = try consumeReservedToken(.assign)
            let rightNode = try assign()

            node = InfixOperatorExpressionNode(
                operator: AssignNode(token: token),
                left: node,
                right: rightNode,
                sourceTokens: Array(tokens[startIndex..<index])
            )
        }

        return node
    }

    // equality = relational ("==" relational | "!=" relational)*
    func equality() throws -> any NodeProtocol {
        let startIndex = index
        var node = try relational()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.equal, _):
                let token = try consumeReservedToken(.equal)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.notEqual, _):
                let token = try consumeReservedToken(.notEqual)
                let rightNode = try relational()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            default:
                return node
            }
        }

        return node
    }

    // relational = add ("<" add | "<=" add | ">" add | ">=" add)*
    func relational() throws -> any NodeProtocol {
        let startIndex = index
        var node = try add()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.lessThan, _):
                let token = try consumeReservedToken(.lessThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.lessThanOrEqual, _):
                let token = try consumeReservedToken(.lessThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.greaterThan, _):
                let token = try consumeReservedToken(.greaterThan)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.greaterThanOrEqual, _):
                let token = try consumeReservedToken(.greaterThanOrEqual)
                let rightNode = try add()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: token),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            default:
                return node
            }
        }

        return node
    }

    // add = mul ("+" mul | "-" mul)*
    func add() throws -> any NodeProtocol {
        let startIndex = index
        var node = try mul()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.add, _):
                let addToken = try consumeReservedToken(.add)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: addToken),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.sub, _):
                let subToken = try consumeReservedToken(.sub)
                let rightNode = try mul()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: subToken),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            default:
                return node
            }
        }

        return node
    }

    // mul = unary ("*" unary | "/" unary)*
    func mul() throws -> any NodeProtocol {
        let startIndex = index

        var node = try unary()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.mul, _):
                let mulToken = try consumeReservedToken(.mul)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: mulToken),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
                )

            case .reserved(.div, _):
                let divToken = try consumeReservedToken(.div)
                let rightNode = try unary()

                node = InfixOperatorExpressionNode(
                    operator: BinaryOperatorNode(token: divToken),
                    left: node,
                    right: rightNode,
                    sourceTokens: Array(tokens[startIndex..<index])
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

        let startIndex = index

        switch tokens[index] {
        case .keyword(.sizeof, _):
            try consumeKeywordToken(.sizeof)

            let unary = try unary()

            // FIXME: どうやって式の型を判断する？
            return IntegerLiteralNode(token: .number("8", sourceIndex: unary.sourceTokens[0].sourceIndex))

        case .reserved(.add, _):
            try consumeReservedToken(.add)

            // 単項+は影響がないので無視する
            return try primary()

        case .reserved(.sub, _):
            let subToken = try consumeReservedToken(.sub)

            // 0 - rightとして認識
            let left = IntegerLiteralNode(token: .number("0", sourceIndex: tokens[index].sourceIndex))
            let right = try primary()

            return InfixOperatorExpressionNode(
                operator: BinaryOperatorNode(token: subToken),
                left: left,
                right: right,
                sourceTokens: Array(tokens[startIndex..<index])
            )

        case .reserved(.mul, _):
            let mulToken = try consumeReservedToken(.mul)
            let right = try unary()

            return PrefixOperatorExpressionNode(
                operator: mulToken,
                right: right,
                sourceTokens: Array(tokens[startIndex..<index])
            )

        case .reserved(.and, _):
            let andToken = try consumeReservedToken(.and)
            let right = try unary()

            return PrefixOperatorExpressionNode(
                operator: andToken,
                right: right,
                sourceTokens: Array(tokens[startIndex..<index])
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

        let startIndex = index

        switch tokens[index] {
        case .reserved(.parenthesisLeft, _):
            try consumeReservedToken(.parenthesisLeft)

            let exprNode = try expr()

            try consumeReservedToken(.parenthesisRight)

            return exprNode

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
                try consumeReservedToken(.parenthesisLeft)

                var argments: [any NodeProtocol] = []
                if index < tokens.count {
                    if case .reserved(.parenthesisRight, _) = tokens[index] {

                    } else {
                        argments = try exprList()
                    }
                }

                try consumeReservedToken(.parenthesisRight)

                return FunctionCallExpressionNode(token: identifierToken, arguments: argments, sourceTokens: Array(tokens[startIndex..<index]))
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

    // exprList = expr ("," expr)*
    func exprList() throws -> [any NodeProtocol] {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }
        var results: [any NodeProtocol] = []
        results.append(try expr())

        while index < tokens.count {
            if case .reserved(.parenthesisRight, _) = tokens[index] {
                break
            }

            try consumeReservedToken(.comma)

            results.append(try expr())
        }

        return results
    }
}
