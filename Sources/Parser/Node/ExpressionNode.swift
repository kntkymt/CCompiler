import Tokenizer

public class InfixOperatorExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .infixOperatorExpr
    public var sourceTokens: [Token] {
        left.sourceTokens + `operator`.sourceTokens + right.sourceTokens
    }
    public var children: [any NodeProtocol] {
        [left, `operator`, right]
    }

    public let left: any NodeProtocol
    public let `operator`: any NodeProtocol
    public let right: any NodeProtocol

    // MARK: - Initializer

    public init(left: any NodeProtocol, operator: any NodeProtocol, right: any NodeProtocol) {
        self.left = left
        self.operator = `operator`
        self.right = right
    }
}

public class PrefixOperatorExpressionNode: NodeProtocol {

    public enum OperatorKind {
        /// `+`
        case plus

        /// `-`
        case minus

        /// `*`
        case reference

        /// `&`
        case address
    }

    // MARK: - Property

    public let kind: NodeKind = .prefixOperatorExpr
    public var sourceTokens: [Token] {
        [`operator`] + expression.sourceTokens
    }
    public var children: [any NodeProtocol] { [expression] }

    public let `operator`: Token
    public let expression: any NodeProtocol

    public var operatorKind: OperatorKind {
        switch `operator` {
        case .reserved(.add, _):
            return .plus

        case .reserved(.sub, _):
            return .minus

        case .reserved(.mul, _):
            return .reference

        case .reserved(.and, _):
            return .address

        default:
            fatalError()
        }
    }

    // MARK: - Initializer

    public init(operator: Token, expression: any NodeProtocol) {
        self.operator = `operator`
        self.expression = expression
    }
}

public class FunctionCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionCallExpr
    public var sourceTokens: [Token] {
        [identifierToken, parenthesisLeftToken] + arguments.flatMap { $0.sourceTokens } + [parenthesisRightToken]
    }
    public var children: [any NodeProtocol] { arguments }

    public let identifierToken: Token
    public let parenthesisLeftToken: Token
    public let arguments: [ExpressionListItemNode]
    public let parenthesisRightToken: Token

    public var functionName: String {
        identifierToken.value
    }

    // MARK: - Initializer

    public init(identifierToken: Token, parenthesisLeftToken: Token, arguments: [ExpressionListItemNode], parenthesisRightToken: Token) {
        self.identifierToken = identifierToken
        self.parenthesisLeftToken = parenthesisLeftToken
        self.arguments = arguments
        self.parenthesisRightToken = parenthesisRightToken
    }
}

public class SubscriptCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .subscriptCallExpr
    public var sourceTokens: [Token] { identifierNode.sourceTokens + [squareLeftToken] + argument.sourceTokens + [squareRightToken] }
    public var children: [any NodeProtocol] { [identifierNode, argument] }

    public let identifierNode: IdentifierNode
    public let squareLeftToken: Token
    public let argument: any NodeProtocol
    public let squareRightToken: Token

    // MARK: - Initializer

    public init(identifierNode: IdentifierNode, squareLeftToken: Token, argument: any NodeProtocol, squareRightToken: Token) {
        self.identifierNode = identifierNode
        self.squareLeftToken = squareLeftToken
        self.argument = argument
        self.squareRightToken = squareRightToken
    }
}

public class ArrayExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .arrayExpr
    public var sourceTokens: [Token] { return  [braceLeft] + exprListNodes.flatMap { $0.sourceTokens } + [braceRight] }
    public var children: [any NodeProtocol] { return exprListNodes.flatMap { $0.children } }

    public let braceLeft: Token
    public let exprListNodes: [ExpressionListItemNode]
    public let braceRight: Token

    // MARK: - Initializer

    public init(braceLeft: Token, exprListNodes: [ExpressionListItemNode], braceRight: Token) {
        self.braceLeft = braceLeft
        self.exprListNodes = exprListNodes
        self.braceRight = braceRight
    }
}

public class ExpressionListItemNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .exprListItem
    public var sourceTokens: [Token] {
        var result = expression.sourceTokens

        if let comma {
            result += [comma]
        }

        return result
    }
    public var children: [any NodeProtocol] {
        [expression]
    }

    public let expression: any NodeProtocol
    public let comma: Token?

    // MARK: - Initializer

    public init(expression: any NodeProtocol, comma: Token? = nil) {
        self.expression = expression
        self.comma = comma
    }
}

public class TupleExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .tupleExpr
    public var sourceTokens: [Token] {
        [parenthesisLeftToken] + expression.sourceTokens + [parenthesisRightToken]
    }
    public var children: [any NodeProtocol] {
        [expression]
    }

    public let parenthesisLeftToken: Token
    public let expression: any NodeProtocol
    public let parenthesisRightToken: Token

    // MARK: - Initializer

    public init(parenthesisLeftToken: Token, expression: any NodeProtocol, parenthesisRightToken: Token) {
        self.parenthesisLeftToken = parenthesisLeftToken
        self.expression = expression
        self.parenthesisRightToken = parenthesisRightToken
    }
}
