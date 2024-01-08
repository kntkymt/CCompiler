import Tokenizer

public class WhileStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .whileStatement
    public var children: [any NodeProtocol] {
        [`while`, parenthesisLeft, condition, parenthesisRight, body]
    }

    public let `while`: TokenNode
    public let parenthesisLeft: TokenNode
    public let condition: any NodeProtocol
    public let parenthesisRight: TokenNode
    public let body: BlockItemNode

    // MARK: - Initializer

    public init(while: TokenNode, parenthesisLeft: TokenNode, condition: any NodeProtocol, parenthesisRight: TokenNode, body: BlockItemNode) {
        self.while = `while`
        self.parenthesisLeft = parenthesisLeft
        self.condition = condition
        self.parenthesisRight = parenthesisRight
        self.body = body
    }
}

public class ForStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .forStatement
    public var children: [any NodeProtocol] {
        [`for`, parenthesisLeft, pre, firstSemicolon, condition, secondSemicolon, post, parenthesisRight, body].compactMap { $0 }
    }

    public let `for`: TokenNode
    public let parenthesisLeft: TokenNode
    public let pre: (any NodeProtocol)?
    public let firstSemicolon: TokenNode
    public let condition: (any NodeProtocol)?
    public let secondSemicolon: TokenNode
    public let post: (any NodeProtocol)?
    public let parenthesisRight: TokenNode
    public let body: BlockItemNode

    // MARK: - Initializer

    public init(
        for: TokenNode,
        parenthesisLeft: TokenNode,
        pre: (any NodeProtocol)?,
        firstSemicolon: TokenNode,
        condition: (any NodeProtocol)?,
        secondSemicolon: TokenNode,
        post: (any NodeProtocol)?,
        parenthesisRight: TokenNode,
        body: BlockItemNode
    ) {
        self.for = `for`
        self.parenthesisLeft = parenthesisLeft
        self.condition = condition
        self.firstSemicolon = firstSemicolon
        self.pre = pre
        self.secondSemicolon = secondSemicolon
        self.post = post
        self.parenthesisRight = parenthesisRight
        self.body = body
    }
}

public class IfStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .ifStatement
    public var children: [any NodeProtocol] {
        ([`if`, parenthesisLeft, condition, parenthesisRight, trueBody, `else`, falseBody] as [(any NodeProtocol)?]).compactMap { $0 }
    }

    public let `if`: TokenNode
    public let parenthesisLeft: TokenNode
    public let condition: any NodeProtocol
    public let parenthesisRight: TokenNode
    public let trueBody: BlockItemNode
    public let `else`: TokenNode?
    public let falseBody: BlockItemNode?

    public init(
        if: TokenNode,
        parenthesisLeft: TokenNode,
        condition: any NodeProtocol,
        parenthesisRight: TokenNode,
        trueBody: BlockItemNode,
        else: TokenNode?,
        falseBody: BlockItemNode?
    ) {
        self.if = `if`
        self.parenthesisLeft = parenthesisLeft
        self.condition = condition
        self.parenthesisRight = parenthesisRight
        self.trueBody = trueBody
        self.else = `else`
        self.falseBody = falseBody
    }
}

public class ReturnStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .returnStatement
    public var children: [any NodeProtocol] {
        [`return`, expression]
    }

    public let `return`: TokenNode
    public let expression: any NodeProtocol

    // MARK: - Initializer

    public init(return: TokenNode, expression: any NodeProtocol) {
        self.return = `return`
        self.expression = expression
    }
}

public class BlockStatementNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .blockStatement
    public var children: [any NodeProtocol] {
        [braceLeft] + items + [braceRight]
    }

    public let braceLeft: TokenNode
    public let items: [BlockItemNode]
    public let braceRight: TokenNode

    // MARK: - Initializer

    public init(braceLeft: TokenNode, items: [BlockItemNode], braceRight: TokenNode) {
        self.braceLeft = braceLeft
        self.items = items
        self.braceRight = braceRight
    }
}

public class BlockItemNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .blockItem
    public var children: [any NodeProtocol] {
        ([item, semicolon] as [(any NodeProtocol)?]).compactMap { $0 }
    }

    public let item: any NodeProtocol
    public let semicolon: TokenNode?

    // MARK: - Initializer

    public init(item: any NodeProtocol, semicolon: TokenNode? = nil) {
        self.item = item
        self.semicolon = semicolon
    }
}

public class FunctionDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionDecl
    public var children: [any NodeProtocol] {
        [returnType, functionName, parenthesisLeft] + parameters + [parenthesisRight, block]
    }

    public let returnType: any NodeProtocol
    public let functionName: TokenNode
    public let parenthesisLeft: TokenNode
    public let parameters: [FunctionParameterNode]
    public let parenthesisRight: TokenNode
    public let block: BlockStatementNode

    // MARK: - Initializer

    public init(
        returnType: any NodeProtocol,
        functionName: TokenNode,
        parenthesisLeft: TokenNode,
        parameters: [FunctionParameterNode],
        parenthesisRight: TokenNode,
        block: BlockStatementNode
    ) {
        self.returnType = returnType
        self.functionName = functionName
        self.parenthesisLeft = parenthesisLeft
        self.parameters = parameters
        self.parenthesisRight = parenthesisRight
        self.block = block
    }
}

public class VariableDeclNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .variableDecl
    public var children: [any NodeProtocol] {
        [type, identifier, equal, initializerExpr].compactMap { $0 }
    }

    public let type: any TypeNodeProtocol
    public let identifier: TokenNode
    public let equal: TokenNode?
    public let initializerExpr: (any NodeProtocol)?

    // MARK: - Initializer

    public init(type: any TypeNodeProtocol, identifier: TokenNode, equal: TokenNode? = nil, initializerExpr: (any NodeProtocol)? = nil) {
        self.type = type
        self.identifier = identifier
        self.equal = equal
        self.initializerExpr = initializerExpr
    }
}

public class FunctionParameterNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionParameter
    public var children: [any NodeProtocol] {
        ([type, identifier, comma] as [(any NodeProtocol)?]).compactMap { $0 }
    }

    public let type: any TypeNodeProtocol
    public let identifier: TokenNode
    public let comma: TokenNode?

    // MARK: - Initializer

    public init(type: any TypeNodeProtocol, identifier: TokenNode, comma: TokenNode? = nil) {
        self.type = type
        self.identifier = identifier
        self.comma = comma
    }
}

public class SourceFileNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .sourceFile
    public var children: [any NodeProtocol] {
        statements
    }

    public let statements: [BlockItemNode]

    // MARK: - Initializer

    public init(statements: [BlockItemNode]) {
        self.statements = statements
    }
}
