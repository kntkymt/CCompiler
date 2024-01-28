import Tokenizer

public class WhileStatementSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .whileStatement
    public var children: [any SyntaxProtocol] {
        [`while`, parenthesisLeft, condition, parenthesisRight, body]
    }

    public let `while`: TokenSyntax
    public let parenthesisLeft: TokenSyntax
    public let condition: any SyntaxProtocol
    public let parenthesisRight: TokenSyntax
    public let body: BlockItemSyntax

    // MARK: - Initializer

    public init(while: TokenSyntax, parenthesisLeft: TokenSyntax, condition: any SyntaxProtocol, parenthesisRight: TokenSyntax, body: BlockItemSyntax) {
        self.while = `while`
        self.parenthesisLeft = parenthesisLeft
        self.condition = condition
        self.parenthesisRight = parenthesisRight
        self.body = body
    }
}

public class ForStatementSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .forStatement
    public var children: [any SyntaxProtocol] {
        [`for`, parenthesisLeft, pre, firstSemicolon, condition, secondSemicolon, post, parenthesisRight, body].compactMap { $0 }
    }

    public let `for`: TokenSyntax
    public let parenthesisLeft: TokenSyntax
    public let pre: (any SyntaxProtocol)?
    public let firstSemicolon: TokenSyntax
    public let condition: (any SyntaxProtocol)?
    public let secondSemicolon: TokenSyntax
    public let post: (any SyntaxProtocol)?
    public let parenthesisRight: TokenSyntax
    public let body: BlockItemSyntax

    // MARK: - Initializer

    public init(
        for: TokenSyntax,
        parenthesisLeft: TokenSyntax,
        pre: (any SyntaxProtocol)?,
        firstSemicolon: TokenSyntax,
        condition: (any SyntaxProtocol)?,
        secondSemicolon: TokenSyntax,
        post: (any SyntaxProtocol)?,
        parenthesisRight: TokenSyntax,
        body: BlockItemSyntax
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

public class IfStatementSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .ifStatement
    public var children: [any SyntaxProtocol] {
        ([`if`, parenthesisLeft, condition, parenthesisRight, trueBody, `else`, falseBody] as [(any SyntaxProtocol)?]).compactMap { $0 }
    }

    public let `if`: TokenSyntax
    public let parenthesisLeft: TokenSyntax
    public let condition: any SyntaxProtocol
    public let parenthesisRight: TokenSyntax
    public let trueBody: BlockItemSyntax
    public let `else`: TokenSyntax?
    public let falseBody: BlockItemSyntax?

    public init(
        if: TokenSyntax,
        parenthesisLeft: TokenSyntax,
        condition: any SyntaxProtocol,
        parenthesisRight: TokenSyntax,
        trueBody: BlockItemSyntax,
        else: TokenSyntax?,
        falseBody: BlockItemSyntax?
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

public class ReturnStatementSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .returnStatement
    public var children: [any SyntaxProtocol] {
        [`return`, expression]
    }

    public let `return`: TokenSyntax
    public let expression: any SyntaxProtocol

    // MARK: - Initializer

    public init(return: TokenSyntax, expression: any SyntaxProtocol) {
        self.return = `return`
        self.expression = expression
    }
}

public class BlockStatementSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .blockStatement
    public var children: [any SyntaxProtocol] {
        [braceLeft] + items + [braceRight]
    }

    public let braceLeft: TokenSyntax
    public let items: [BlockItemSyntax]
    public let braceRight: TokenSyntax

    // MARK: - Initializer

    public init(braceLeft: TokenSyntax, items: [BlockItemSyntax], braceRight: TokenSyntax) {
        self.braceLeft = braceLeft
        self.items = items
        self.braceRight = braceRight
    }
}

public class BlockItemSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .blockItem
    public var children: [any SyntaxProtocol] {
        ([item, semicolon] as [(any SyntaxProtocol)?]).compactMap { $0 }
    }

    public let item: any SyntaxProtocol
    public let semicolon: TokenSyntax?

    // MARK: - Initializer

    public init(item: any SyntaxProtocol, semicolon: TokenSyntax? = nil) {
        self.item = item
        self.semicolon = semicolon
    }
}

public class FunctionDeclSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .functionDecl
    public var children: [any SyntaxProtocol] {
        [returnType, functionName, parenthesisLeft] + parameters + [parenthesisRight, block]
    }

    public let returnType: any TypeSyntaxProtocol
    public let functionName: TokenSyntax
    public let parenthesisLeft: TokenSyntax
    public let parameters: [FunctionParameterSyntax]
    public let parenthesisRight: TokenSyntax
    public let block: BlockStatementSyntax

    // MARK: - Initializer

    public init(
        returnType: any TypeSyntaxProtocol,
        functionName: TokenSyntax,
        parenthesisLeft: TokenSyntax,
        parameters: [FunctionParameterSyntax],
        parenthesisRight: TokenSyntax,
        block: BlockStatementSyntax
    ) {
        self.returnType = returnType
        self.functionName = functionName
        self.parenthesisLeft = parenthesisLeft
        self.parameters = parameters
        self.parenthesisRight = parenthesisRight
        self.block = block
    }
}

public class VariableDeclSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .variableDecl
    public var children: [any SyntaxProtocol] {
        [type, identifier, equal, initializerExpr].compactMap { $0 }
    }

    public let type: any TypeSyntaxProtocol
    public let identifier: TokenSyntax
    public let equal: TokenSyntax?
    public let initializerExpr: (any SyntaxProtocol)?

    // MARK: - Initializer

    public init(type: any TypeSyntaxProtocol, identifier: TokenSyntax, equal: TokenSyntax? = nil, initializerExpr: (any SyntaxProtocol)? = nil) {
        self.type = type
        self.identifier = identifier
        self.equal = equal
        self.initializerExpr = initializerExpr
    }
}

public class FunctionParameterSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .functionParameter
    public var children: [any SyntaxProtocol] {
        ([type, identifier, comma] as [(any SyntaxProtocol)?]).compactMap { $0 }
    }

    public let type: any TypeSyntaxProtocol
    public let identifier: TokenSyntax
    public let comma: TokenSyntax?

    // MARK: - Initializer

    public init(type: any TypeSyntaxProtocol, identifier: TokenSyntax, comma: TokenSyntax? = nil) {
        self.type = type
        self.identifier = identifier
        self.comma = comma
    }
}

public class SourceFileSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .sourceFile
    public var children: [any SyntaxProtocol] {
        statements + [endOfFile]
    }

    public let statements: [BlockItemSyntax]
    public let endOfFile: TokenSyntax

    // MARK: - Initializer

    public init(statements: [BlockItemSyntax], endOfFile: TokenSyntax) {
        self.statements = statements
        self.endOfFile = endOfFile
    }
}
