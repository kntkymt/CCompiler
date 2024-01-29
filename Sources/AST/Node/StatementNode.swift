import Tokenizer

public class WhileStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .whileStatement
    public var children: [any NodeProtocol] {
        [condition, body]
    }
    public let sourceRange: SourceRange

    public let condition: any NodeProtocol
    public let body: any NodeProtocol

    // MARK: - Initializer

    public init(
        condition: any NodeProtocol,
        body: any NodeProtocol,
        sourceRange: SourceRange
    ) {
        self.condition = condition
        self.body = body
        self.sourceRange = sourceRange
    }
}

public class ForStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .forStatement
    public var children: [any NodeProtocol] {
        [pre, condition, post, body].compactMap { $0 }
    }
    public let sourceRange: SourceRange

    public let pre: (any NodeProtocol)?
    public let condition: (any NodeProtocol)?
    public let post: (any NodeProtocol)?
    public let body: any NodeProtocol

    // MARK: - Initializer

    public init(
        pre: (any NodeProtocol)?,
        condition: (any NodeProtocol)?,
        post: (any NodeProtocol)?,
        body: any NodeProtocol,
        sourceRange: SourceRange
    ) {
        self.condition = condition
        self.pre = pre
        self.post = post
        self.body = body
        self.sourceRange = sourceRange
    }
}

public class IfStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .ifStatement
    public var children: [any NodeProtocol] {
        ([condition, trueBody, falseBody] as [(any NodeProtocol)?]).compactMap { $0 }
    }
    public let sourceRange: SourceRange

    public let condition: any NodeProtocol
    public let trueBody: any NodeProtocol
    public let falseBody: (any NodeProtocol)?

    public init(
        condition: any NodeProtocol,
        trueBody: any NodeProtocol,
        falseBody: (any NodeProtocol)?,
        sourceRange: SourceRange
    ) {
        self.condition = condition
        self.trueBody = trueBody
        self.falseBody = falseBody
        self.sourceRange = sourceRange
    }
}

public class ReturnStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .returnStatement
    public var children: [any NodeProtocol] {
        [expression]
    }
    public let sourceRange: SourceRange

    public let expression: any NodeProtocol

    // MARK: - Initializer

    public init(expression: any NodeProtocol, sourceRange: SourceRange) {
        self.expression = expression
        self.sourceRange = sourceRange
    }
}

public class BlockStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .blockStatement
    public var children: [any NodeProtocol] {
        items
    }
    public let sourceRange: SourceRange

    public let items: [any NodeProtocol]

    // MARK: - Initializer

    public init(items: [any NodeProtocol], sourceRange: SourceRange) {
        self.items = items
        self.sourceRange = sourceRange
    }
}

public class FunctionDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionDecl
    public var children: [any NodeProtocol] {
        [returnType] + parameters + [block]
    }
    public let sourceRange: SourceRange

    public let returnType: any TypeNodeProtocol
    public let functionName: String
    public let parameters: [FunctionParameterNode]
    public let block: BlockStatementNode

    // MARK: - Initializer

    public init(
        returnType: any TypeNodeProtocol,
        functionName: String,
        parameters: [FunctionParameterNode],
        block: BlockStatementNode,
        sourceRange: SourceRange
    ) {
        self.returnType = returnType
        self.functionName = functionName
        self.parameters = parameters
        self.block = block
        self.sourceRange = sourceRange
    }
}

public class VariableDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .variableDecl
    public var children: [any NodeProtocol] {
        [type, initializerExpr].compactMap { $0 }
    }
    public let sourceRange: SourceRange

    public let type: any TypeNodeProtocol
    public let identifierName: String
    public let initializerExpr: (any NodeProtocol)?

    // MARK: - Initializer

    public init(type: any TypeNodeProtocol, identifierName: String, initializerExpr: (any NodeProtocol)? = nil, sourceRange: SourceRange) {
        self.type = type
        self.identifierName = identifierName
        self.initializerExpr = initializerExpr
        self.sourceRange = sourceRange
    }
}

public class FunctionParameterNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionParameter
    public var children: [any NodeProtocol] {
        [type]
    }
    public let sourceRange: SourceRange

    public let type: any TypeNodeProtocol
    public let identifierName: String

    // MARK: - Initializer

    public init(type: any TypeNodeProtocol, identifierName: String, sourceRange: SourceRange) {
        self.type = type
        self.identifierName = identifierName
        self.sourceRange = sourceRange
    }
}

public class SourceFileNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .sourceFile
    public var children: [any NodeProtocol] {
        statements
    }
    public let sourceRange: SourceRange

    public let statements: [any NodeProtocol]

    // MARK: - Initializer

    public init(statements: [any NodeProtocol], sourceRange: SourceRange) {
        self.statements = statements
        self.sourceRange = sourceRange
    }
}
