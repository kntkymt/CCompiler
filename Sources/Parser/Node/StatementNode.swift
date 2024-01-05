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

public class FunctionDeclNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .functionDecl
    public var sourceTokens: [Token] {
        returnTypeNode.sourceTokens +
        [functionNameToken, parenthesisLeftToken] +
        parameterNodes.flatMap { $0.sourceTokens } +
        [parenthesisRightToken] +
        block.sourceTokens
    }
    public var children: [any NodeProtocol] { [returnTypeNode] + parameterNodes + [block] }

    public let returnTypeNode: any NodeProtocol
    public let functionNameToken: Token
    public let parenthesisLeftToken: Token
    public let parameterNodes: [VariableDeclNode]
    public let parenthesisRightToken: Token
    public let block: BlockStatementNode

    public var functionName: String {
        functionNameToken.value
    }

    // MARK: - Initializer

    init(
        returnTypeNode: any NodeProtocol,
        functionNameToken: Token,
        parenthesisLeftToken: Token,
        parameterNodes: [VariableDeclNode],
        parenthesisRightToken: Token,
        block: BlockStatementNode
    ) {
        self.returnTypeNode = returnTypeNode
        self.functionNameToken = functionNameToken
        self.parenthesisLeftToken = parenthesisLeftToken
        self.parameterNodes = parameterNodes
        self.parenthesisRightToken = parenthesisRightToken
        self.block = block
    }
}

public class VariableDeclNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .variableDecl
    public var sourceTokens: [Token] {
        type.sourceTokens + [identifierToken]
    }
    public var children: [any NodeProtocol] { [type] }

    public let type: any TypeNodeProtocol
    public let identifierToken: Token
    public let initializerToken: Token?
    public let initializerExpr: (any NodeProtocol)?

    public var identifierName: String {
        identifierToken.value
    }

    // MARK: - Initializer

    init(type: any TypeNodeProtocol, identifierToken: Token, initializerToken: Token? = nil, initializerExpr: (any NodeProtocol)? = nil) {
        self.type = type
        self.identifierToken = identifierToken
        self.initializerToken = initializerToken
        self.initializerExpr = initializerExpr
    }
}

public class SourceFileNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .sourceFile
    public var sourceTokens: [Token] {
        functions.flatMap { $0.sourceTokens } + globalVariables.flatMap { $0.sourceTokens }
    }

    public var children: [any NodeProtocol] {
        functions + globalVariables
    }

    public let functions: [FunctionDeclNode]
    public let globalVariables: [VariableDeclNode]

    // MARK: - Initializer

    init(functions: [FunctionDeclNode], globalVariables: [VariableDeclNode]) {
        self.functions = functions
        self.globalVariables = globalVariables
    }
}
