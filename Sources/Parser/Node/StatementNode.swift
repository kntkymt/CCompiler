import Tokenizer

public class WhileStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .whileStatement
    public var sourceTokens: [Token] {
        [whileToken, parenthesisLeftToken] + condition.sourceTokens + [parenthesisRightToken] + body.sourceTokens
    }
    public var children: [any NodeProtocol] { [condition, body] }

    public let whileToken: Token
    public let parenthesisLeftToken: Token
    public let condition: any NodeProtocol
    public let parenthesisRightToken: Token
    public let body: BlockItemNode

    // MARK: - Initializer

    public init(whileToken: Token, parenthesisLeftToken: Token, condition: any NodeProtocol, parenthesisRightToken: Token, body: BlockItemNode) {
        self.whileToken = whileToken
        self.parenthesisLeftToken = parenthesisLeftToken
        self.condition = condition
        self.parenthesisRightToken = parenthesisRightToken
        self.body = body
    }
}

public class ForStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .forStatement
    public var sourceTokens: [Token] {
        var result = [forToken, parenthesisLeftToken]

        if let pre {
            result += pre.sourceTokens
        }

        result += [firstSemicolonToken]

        if let condition {
            result += condition.sourceTokens
        }

        result += [secondSemicolonToken]

        if let post {
            result += post.sourceTokens
        }

        result += [parenthesisRightToken]

        result += body.sourceTokens

        return result
    }
    public var children: [any NodeProtocol] {
        [pre, condition, post, body].compactMap { $0 }
    }

    public let forToken: Token
    public let parenthesisLeftToken: Token
    public let pre: (any NodeProtocol)?
    public let firstSemicolonToken: Token
    public let condition: (any NodeProtocol)?
    public let secondSemicolonToken: Token
    public let post: (any NodeProtocol)?
    public let parenthesisRightToken: Token
    public let body: BlockItemNode

    // MARK: - Initializer

    public init(
        forToken: Token,
        parenthesisLeftToken: Token,
        pre: (any NodeProtocol)?,
        firstSemicolonToken: Token,
        condition: (any NodeProtocol)?,
        secondSemicolonToken: Token,
        post: (any NodeProtocol)?,
        parenthesisRightToken: Token,
        body: BlockItemNode
    ) {
        self.forToken = forToken
        self.parenthesisLeftToken = parenthesisLeftToken
        self.condition = condition
        self.firstSemicolonToken = firstSemicolonToken
        self.pre = pre
        self.secondSemicolonToken = secondSemicolonToken
        self.post = post
        self.parenthesisRightToken = parenthesisRightToken
        self.body = body
    }
}

public class IfStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .ifStatement
    public var sourceTokens: [Token] {
        var result = [ifToken, parenthesisLeftToken] + condition.sourceTokens + [parenthesisRightToken] + trueBody.sourceTokens

        if let elseToken {
            result.append(elseToken)
        }

        return result + (falseBody?.sourceTokens ?? [])
    }
    public var children: [any NodeProtocol] {
        [condition, trueBody, falseBody as (any NodeProtocol)?].compactMap { $0 }
    }

    public let ifToken: Token
    public let parenthesisLeftToken: Token
    public let condition: any NodeProtocol
    public let parenthesisRightToken: Token
    public let trueBody: BlockItemNode
    public let elseToken: Token?
    public let falseBody: BlockItemNode?

    public init(
        ifToken: Token,
        parenthesisLeftToken: Token,
        condition: any NodeProtocol,
        parenthesisRightToken: Token,
        trueBody: BlockItemNode,
        elseToken: Token?,
        falseBody: BlockItemNode?
    ) {
        self.ifToken = ifToken
        self.parenthesisLeftToken = parenthesisLeftToken
        self.condition = condition
        self.parenthesisRightToken = parenthesisRightToken
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

    public init(returnToken: Token, expression: any NodeProtocol) {
        self.returnToken = returnToken
        self.expression = expression
    }
}

public class BlockStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .blockStatement
    public var sourceTokens: [Token] {
        [braceLeftToken] + items.flatMap { $0.sourceTokens } + [braceRightToken]
    }
    public var children: [any NodeProtocol] { items }

    public let braceLeftToken: Token
    public let items: [BlockItemNode]
    public let braceRightToken: Token

    // MARK: - Initializer

    public init(braceLeftToken: Token, items: [BlockItemNode], braceRightToken: Token) {
        self.braceLeftToken = braceLeftToken
        self.items = items
        self.braceRightToken = braceRightToken
    }
}

public class BlockItemNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .blockItem
    public var sourceTokens: [Token] {
        var result = item.sourceTokens

        if let semicolonToken {
            result += [semicolonToken]
        }

        return result
    }
    public var children: [any NodeProtocol] {
        [item]
    }

    public let item: any NodeProtocol
    public let semicolonToken: Token?

    // MARK: - Initializer

    public init(item: any NodeProtocol, semicolonToken: Token? = nil) {
        self.item = item
        self.semicolonToken = semicolonToken
    }
}

public class FunctionDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionDecl
    public var sourceTokens: [Token] {
        returnTypeNode.sourceTokens 
        + [functionNameToken, parenthesisLeftToken]
        + parameterNodes.flatMap { $0.sourceTokens }
        + [parenthesisRightToken]
        + block.sourceTokens
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

    public init(
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

    public init(type: any TypeNodeProtocol, identifierToken: Token, initializerToken: Token? = nil, initializerExpr: (any NodeProtocol)? = nil) {
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
        var result = type.sourceTokens + [identifierToken]

        if let commaToken {
            result += [commaToken]
        }

        return result
    }
    public var children: [any NodeProtocol] { [type] }

    public let type: any TypeNodeProtocol
    public let identifierToken: Token
    public let commaToken: Token?

    public var identifierName: String {
        identifierToken.value
    }

    // MARK: - Initializer

    public init(type: any TypeNodeProtocol, identifierToken: Token, commaToken: Token? = nil) {
        self.type = type
        self.identifierToken = identifierToken
        self.commaToken = commaToken
    }
}

public class SourceFileNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .sourceFile
    public var sourceTokens: [Token] {
        statements.flatMap { $0.sourceTokens }
    }

    public var children: [any NodeProtocol] {
        statements
    }

    public let statements: [BlockItemNode]

    // MARK: - Initializer

    public init(statements: [BlockItemNode]) {
        self.statements = statements
    }
}
