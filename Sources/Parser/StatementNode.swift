import Tokenizer

public class WhileStatementNode: NodeProtocol {

    public var kind: NodeKind = .whileStatement

    public let token: Token
    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { [condition, body] }

    public var condition: any NodeProtocol
    public var body: any NodeProtocol

    init(token: Token, condition: any NodeProtocol, body: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.condition = condition
        self.body = body
        self.sourceTokens = sourceTokens
    }
}

public class ForStatementNode: NodeProtocol {

    public var kind: NodeKind = .forStatement

    public let token: Token

    public var condition: (any NodeProtocol)?
    public var pre: (any NodeProtocol)?
    public var post: (any NodeProtocol)?
    public var body: any NodeProtocol

    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] {
        var result: [any NodeProtocol] = [body]

        if let pre {
            result.append(pre)
        }

        if let post {
            result.append(post)
        }

        if let condition {
            result.append(condition)
        }

        return result
    }

    init(token: Token, condition: (any NodeProtocol)?, pre: (any NodeProtocol)?, post: (any NodeProtocol)?, body: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.condition = condition
        self.pre = pre
        self.post = post
        self.body = body
        self.sourceTokens = sourceTokens
    }
}

public class IfStatementNode: NodeProtocol {

    public var kind: NodeKind = .ifStatement

    public let ifToken: Token
    public let elseToken: Token?

    public var condition: any NodeProtocol
    public var trueBody: any NodeProtocol
    public var falseBody: (any NodeProtocol)?

    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] {
        var result: [any NodeProtocol] = [condition, trueBody]

        if let falseBody {
            result.append(falseBody)
        }

        return result
    }

    init(ifToken: Token, condition: any NodeProtocol, trueBody: any NodeProtocol, elseToken: Token?, falseBody: (any NodeProtocol)?, sourceTokens: [Token]) {
        self.ifToken = ifToken
        self.condition = condition
        self.trueBody = trueBody
        self.elseToken = elseToken
        self.falseBody = falseBody
        self.sourceTokens = sourceTokens
    }
}

public class ReturnStatementNode: NodeProtocol {

    public var kind: NodeKind = .returnStatement
    public let token: Token

    public var expression: any NodeProtocol

    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { [expression] }

    init(token: Token, expression: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.expression = expression
        self.sourceTokens = sourceTokens
    }
}

public class BlockStatementNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .blockStatement
    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { statements }

    public var statements: [any NodeProtocol]

    // MARK: - Initializer

    init(statements: [any NodeProtocol], sourceTokens: [Token]) {
        self.statements = statements
        self.sourceTokens = sourceTokens
    }
}
