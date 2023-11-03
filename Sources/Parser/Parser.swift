import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(index: Int)
}

public func parse(tokens: [Token]) throws -> Node {
    if tokens.isEmpty {
        throw ParseError.invalidSyntax(index: 0)
    }
    var index = 0

    @discardableResult
    func consumeToken(_ tokenKind: TokenKind) throws -> Token {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        if tokens[index].kind == tokenKind {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }

    // expr = mul ("+" mul | "-" mul)*
    func expr() throws -> Node {
        var node = try mul()

        while index < tokens.count {
            switch tokens[index].kind {
            case .add:
                let addToken = try consumeToken(.add)
                let rightNode = try mul()

                node = Node(kind: .add, left: node, right: rightNode, token: addToken)

            case .sub:
                let subToken = try consumeToken(.sub)
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
            switch tokens[index].kind {
            case .mul:
                let mulToken = try consumeToken(.mul)
                let rightNode = try unary()

                node = Node(kind: .mul, left: node, right: rightNode, token: mulToken)

            case .div:
                let divToken = try consumeToken(.div)
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

        switch tokens[index].kind {
        case .add:
            try consumeToken(.add)
            
            // 単項+は影響がないので無視する
            return try primary()

        case .sub:
            let subToken = try consumeToken(.sub)

            // 0 - rightとして認識
            let left = Node(kind: .number, left: nil, right: nil, token: Token(kind: .number, value: "0", sourceIndex: tokens[index].sourceIndex))
            let right = try primary()

            return Node(kind: .sub, left: left, right: right, token: subToken)

        default:
            return try primary()
        }
    }

    // primary = num | "(" expr ")"
    func primary() throws -> Node {
        if index >= tokens.count {
            throw ParseError.invalidSyntax(index: tokens.last.map { $0.sourceIndex + 1 } ?? 0)
        }

        switch tokens[index].kind {
        case .parenthesisLeft:
            try consumeToken(.parenthesisLeft)

            let exprNode = try expr()

            try consumeToken(.parenthesisRight)

            return exprNode

        case .number:

            let numberToken = try consumeToken(.number)
            let numberNode = Node(kind: .number, left: nil, right: nil, token: numberToken)

            return numberNode

        default:
            throw ParseError.invalidSyntax(index: tokens[index].sourceIndex)
        }
    }


    return try expr()
}
