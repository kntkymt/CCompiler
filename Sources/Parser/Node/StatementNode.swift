import Tokenizer

public class WhileStatementNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .whileStatement
    public var sourceTokens: [Token] {
        [whileToken] + condition.sourceTokens + body.sourceTokens
    }
    public var children: [any NodeProtocol] { [condition, body] }

    public let whileToken: Token
    public let condition: any NodeProtocol
    public let body: any NodeProtocol

    // MARK: - Initializer

    init(whileToken: Token, condition: any NodeProtocol, body: any NodeProtocol) {
        self.whileToken = whileToken
        self.condition = condition
        self.body = body
    }
}

public class ForStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .forStatement
    public var sourceTokens: [Token] {
        [forToken] + (pre?.sourceTokens ?? []) + (condition?.sourceTokens ?? []) + (post?.sourceTokens ?? [])
    }
    public var children: [any NodeProtocol] {
        [pre, condition, post, body].compactMap { $0 }
    }

    public let forToken: Token
    public var pre: (any NodeProtocol)?
    public var condition: (any NodeProtocol)?
    public var post: (any NodeProtocol)?
    public var body: any NodeProtocol

    // MARK: - Initializer

    init(forToken: Token, pre: (any NodeProtocol)?, condition: (any NodeProtocol)?, post: (any NodeProtocol)?, body: any NodeProtocol) {
        self.forToken = forToken
        self.condition = condition
        self.pre = pre
        self.post = post
        self.body = body
    }
}

public class IfStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .ifStatement
    public var sourceTokens: [Token] {
        var result = [ifToken] + condition.sourceTokens + trueBody.sourceTokens

        if let elseToken {
            result.append(elseToken)
        }

        return result + (falseBody?.sourceTokens ?? [])
    }
    public var children: [any NodeProtocol] {
        [condition, trueBody, falseBody].compactMap { $0 }
    }

    public let ifToken: Token
    public let condition: any NodeProtocol
    public let trueBody: any NodeProtocol
    public let elseToken: Token?
    public let falseBody: (any NodeProtocol)?

    init(ifToken: Token, condition: any NodeProtocol, trueBody: any NodeProtocol, elseToken: Token?, falseBody: (any NodeProtocol)?) {
        self.ifToken = ifToken
        self.condition = condition
        self.trueBody = trueBody
        self.elseToken = elseToken
        self.falseBody = falseBody
    }
}

public class ReturnStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .returnStatement
    public var sourceTokens: [Token] { [returnToken] + expression.sourceTokens }
    public var children: [any NodeProtocol] { [expression] }

    public let returnToken: Token
    public let expression: any NodeProtocol

    // MARK: - Initializer

    init(returnToken: Token, expression: any NodeProtocol) {
        self.returnToken = returnToken
        self.expression = expression
    }
}

public class BlockStatementNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .blockStatement
    public var sourceTokens: [Token] {
        statements.flatMap { $0.sourceTokens }
    }
    public var children: [any NodeProtocol] { statements }

    public let statements: [any NodeProtocol]

    // MARK: - Initializer

    init(statements: [any NodeProtocol]) {
        self.statements = statements
    }
}

public class FunctionDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionDecl
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
    public let parameterNodes: [FunctionParameterNode]
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
        parameterNodes: [FunctionParameterNode],
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

    public let kind: NodeKind = .variableDecl
    public var sourceTokens: [Token] {
        var tokens = type.sourceTokens + [identifierToken]

        if let initializerToken {
            tokens += [initializerToken]
        }

        if let initializerExpr {
            tokens += initializerExpr.sourceTokens
        }

        return tokens
    }
    public var children: [any NodeProtocol] {
        [type, initializerExpr].compactMap { $0 }
    }

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

public class FunctionParameterNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionParameter
    public var sourceTokens: [Token] {
        type.sourceTokens + [identifierToken]
    }
    public var children: [any NodeProtocol] { [type] }

    public let type: any TypeNodeProtocol
    public let identifierToken: Token

    public var identifierName: String {
        identifierToken.value
    }

    // MARK: - Initializer

    init(type: any TypeNodeProtocol, identifierToken: Token) {
        self.type = type
        self.identifierToken = identifierToken
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
