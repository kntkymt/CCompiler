import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(index: Int)
}

public func parse(tokens: [Token]) throws -> [Node] {
    if tokens.isEmpty {
        throw ParseError.invalidSyntax(index: 0)
    }
    var index = 0

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

    // MARK: - Syntax

    // program = stmt*
    func program() throws -> [Node] {
        var nodes: [Node] = []

        while index < tokens.count {
            nodes.append(try stmt())
        }

        return nodes
    }

    // stmt    = expr ";"
    //         | "return" expr ";"
    func stmt() throws -> Node {
        let node: Node

        if case .keyword(.return, _) = tokens[index] {
            let token = try consumeKeywordToken(.return)

            let left = try expr()
            node = Node(kind: .return, left: left, right: nil, token: token)
        } else {
            node = try expr()
        }

        try consumeReservedToken(.semicolon)

        return node
    }

    // expr = assign
    func expr() throws -> Node {
        try assign()
    }

    // assign = equality ("=" assign)?
    func assign() throws -> Node {
        var node = try equality()

        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if case .reserved(.assign, _) = tokens[index] {
            let token = try consumeReservedToken(.assign)
            let rightNode = try assign()

            node = Node(kind: .assign, left: node, right: rightNode, token: token)
        }

        return node
    }

    // equality = relational ("==" relational | "!=" relational)*
    func equality() throws -> Node {
        var node = try relational()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.equal, _):
                let token = try consumeReservedToken(.equal)
                let rightNode = try relational()

                node = Node(kind: .equal, left: node, right: rightNode, token: token)

            case .reserved(.notEqual, _):
                let token = try consumeReservedToken(.notEqual)
                let rightNode = try relational()

                node = Node(kind: .notEqual, left: node, right: rightNode, token: token)

            default:
                return node
            }
        }

        return node
    }

    // relational = add ("<" add | "<=" add | ">" add | ">=" add)*
    func relational() throws -> Node {
        var node = try add()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.lessThan, _):
                let token = try consumeReservedToken(.lessThan)
                let rightNode = try add()

                node = Node(kind: .lessThan, left: node, right: rightNode, token: token)

            case .reserved(.lessThanOrEqual, _):
                let token = try consumeReservedToken(.lessThanOrEqual)
                let rightNode = try add()

                node = Node(kind: .lessThanOrEqual, left: node, right: rightNode, token: token)

            case .reserved(.greaterThan, _):
                let token = try consumeReservedToken(.greaterThan)
                let rightNode = try add()

                node = Node(kind: .lessThan, left: rightNode, right: node, token: token)

            case .reserved(.greaterThanOrEqual, _):
                let token = try consumeReservedToken(.greaterThanOrEqual)
                let rightNode = try add()

                node = Node(kind: .lessThanOrEqual, left: rightNode, right: node, token: token)

            default:
                return node
            }
        }

        return node
    }

    // add = mul ("+" mul | "-" mul)*
    func add() throws -> Node {
        var node = try mul()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.add, _):
                let addToken = try consumeReservedToken(.add)
                let rightNode = try mul()

                node = Node(kind: .add, left: node, right: rightNode, token: addToken)

            case .reserved(.sub, _):
                let subToken = try consumeReservedToken(.sub)
                let rightNode = try mul()

                node = Node(kind: .sub, left: node, right: rightNode, token: subToken)

            default:
                return node
            }
        }

        return node
    }

    // mul = unary ("*" unary | "/" unary)*
    func mul() throws -> Node {
        var node = try unary()

        while index < tokens.count {
            switch tokens[index] {
            case .reserved(.mul, _):
                let mulToken = try consumeReservedToken(.mul)
                let rightNode = try unary()

                node = Node(kind: .mul, left: node, right: rightNode, token: mulToken)

            case .reserved(.div, _):
                let divToken = try consumeReservedToken(.div)
                let rightNode = try unary()

                node = Node(kind: .div, left: node, right: rightNode, token: divToken)

            default:
                return node
            }
        }

        return node
    }

    // unary = ("+" | "-")? primary
    func unary() throws -> Node {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        switch tokens[index] {
        case .reserved(.add, _):
            try consumeReservedToken(.add)

            // 単項+は影響がないので無視する
            return try primary()

        case .reserved(.sub, _):
            let subToken = try consumeReservedToken(.sub)

            // 0 - rightとして認識
            let left = Node(kind: .number, left: nil, right: nil, token: .number("0", sourceIndex: tokens[index].sourceIndex))
            let right = try primary()

            return Node(kind: .sub, left: left, right: right, token: subToken)

        default:
            return try primary()
        }
    }

    // primary = num | ident | "(" expr ")"
    func primary() throws -> Node {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        switch tokens[index] {
        case .reserved(.parenthesisLeft, _):
            try consumeReservedToken(.parenthesisLeft)

            let exprNode = try expr()

            try consumeReservedToken(.parenthesisRight)

            return exprNode

        case .number:
            let numberToken = try consumeNumberToken()
            let numberNode = Node(kind: .number, left: nil, right: nil, token: numberToken)

            return numberNode

        case .identifier:
            let identifierToken = try consumeIdentifierToken()
            let identifierNode = Node(kind: .localVariable, left: nil, right: nil, token: identifierToken)

            return identifierNode

        default:
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }


    return try program()
}
