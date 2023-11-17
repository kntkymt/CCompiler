import Tokenizer

public class WhileStatementNode: NodeProtocol {

    public var kind: NodeKind = .whileStatement

    public let token: Token
    public let sourceTokens: [Token]

    public var condition: any NodeProtocol
    public var body: any NodeProtocol

    init(token: Token, condition: any NodeProtocol, body: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.condition = condition
        self.body = body
        self.sourceTokens = sourceTokens
    }

    public static func == (lhs: WhileStatementNode, rhs: WhileStatementNode) -> Bool {
        lhs.sourceTokens == rhs.sourceTokens
        && AnyNode(lhs.condition) == AnyNode(rhs.condition)
        && AnyNode(lhs.body) == AnyNode(rhs.body)
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

    init(token: Token, condition: (any NodeProtocol)?, pre: (any NodeProtocol)?, post: (any NodeProtocol)?, body: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.condition = condition
        self.pre = pre
        self.post = post
        self.body = body
        self.sourceTokens = sourceTokens
    }

    public static func == (lhs: ForStatementNode, rhs: ForStatementNode) -> Bool {
        lhs.sourceTokens == rhs.sourceTokens
        && AnyNode(lhs.condition) == AnyNode(rhs.condition)
        && AnyNode(lhs.pre) == AnyNode(rhs.pre)
        && AnyNode(lhs.post) == AnyNode(rhs.post)
        && AnyNode(lhs.body) == AnyNode(rhs.body)
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

    init(ifToken: Token, condition: any NodeProtocol, trueBody: any NodeProtocol, elseToken: Token?, falseBody: (any NodeProtocol)?, sourceTokens: [Token]) {
        self.ifToken = ifToken
        self.condition = condition
        self.trueBody = trueBody
        self.elseToken = elseToken
        self.falseBody = falseBody
        self.sourceTokens = sourceTokens
    }

    public static func == (lhs: IfStatementNode, rhs: IfStatementNode) -> Bool {
        lhs.sourceTokens == rhs.sourceTokens
        && AnyNode(lhs.condition) == AnyNode(rhs.condition)
        && AnyNode(lhs.trueBody) == AnyNode(rhs.trueBody)
        && AnyNode(lhs.falseBody) == AnyNode(rhs.falseBody)
    }
}

public class ReturnStatementNode: NodeProtocol {

    public var kind: NodeKind = .returnStatement
    public let token: Token

    public var expression: any NodeProtocol

    public let sourceTokens: [Token]

    init(token: Token, expression: any NodeProtocol, sourceTokens: [Token]) {
        self.token = token
        self.expression = expression
        self.sourceTokens = sourceTokens
    }

    public static func == (lhs: ReturnStatementNode, rhs: ReturnStatementNode) -> Bool {
        lhs.sourceTokens == rhs.sourceTokens
        && AnyNode(lhs.expression) == AnyNode(rhs.expression)
    }
}

