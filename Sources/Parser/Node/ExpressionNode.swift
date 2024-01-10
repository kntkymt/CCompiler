import Tokenizer

public class InfixOperatorExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .infixOperatorExpr
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
    public var children: [any NodeProtocol] {
        [`operator`, expression]
    }

    public let `operator`: TokenNode
    public let expression: any NodeProtocol

    public var operatorKind: OperatorKind {
        switch `operator`.tokenKind {
        case .reserved(.add):
            return .plus

        case .reserved(.sub):
            return .minus

        case .reserved(.mul):
            return .reference

        case .reserved(.and):
            return .address

        default:
            fatalError()
        }
    }

    // MARK: - Initializer

    public init(operator: TokenNode, expression: any NodeProtocol) {
        self.operator = `operator`
        self.expression = expression
    }
}

public class FunctionCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionCallExpr
    public var children: [any NodeProtocol] {
        [identifier, parenthesisLeft] + arguments + [parenthesisRight]
    }

    public let identifier: TokenNode
    public let parenthesisLeft: TokenNode
    public let arguments: [ExpressionListItemNode]
    public let parenthesisRight: TokenNode

    // MARK: - Initializer

    public init(identifier: TokenNode, parenthesisLeft: TokenNode, arguments: [ExpressionListItemNode], parenthesisRight: TokenNode) {
        self.identifier = identifier
        self.parenthesisLeft = parenthesisLeft
        self.arguments = arguments
        self.parenthesisRight = parenthesisRight
    }
}

public class SubscriptCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .subscriptCallExpr
    public var children: [any NodeProtocol] {
        [identifier, squareLeft, argument, squareRight]
    }

    public let identifier: IdentifierNode
    public let squareLeft: TokenNode
    public let argument: any NodeProtocol
    public let squareRight: TokenNode

    // MARK: - Initializer

    public init(identifier: IdentifierNode, squareLeft: TokenNode, argument: any NodeProtocol, squareRight: TokenNode) {
        self.identifier = identifier
        self.squareLeft = squareLeft
        self.argument = argument
        self.squareRight = squareRight
    }
}

public class ArrayExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .arrayExpr
    public var children: [any NodeProtocol] {
        [braceLeft] + exprListNodes + [braceRight]
    }

    public let braceLeft: TokenNode
    public let exprListNodes: [ExpressionListItemNode]
    public let braceRight: TokenNode

    // MARK: - Initializer

    public init(braceLeft: TokenNode, exprListNodes: [ExpressionListItemNode], braceRight: TokenNode) {
        self.braceLeft = braceLeft
        self.exprListNodes = exprListNodes
        self.braceRight = braceRight
    }
}

public class ExpressionListItemNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .exprListItem
    public var children: [any NodeProtocol] {
        ([expression, comma] as [(any NodeProtocol)?]).compactMap { $0 }
    }

    public let expression: any NodeProtocol
    public let comma: TokenNode?

    // MARK: - Initializer

    public init(expression: any NodeProtocol, comma: TokenNode? = nil) {
        self.expression = expression
        self.comma = comma
    }
}

public class TupleExpressionNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .tupleExpr
    public var children: [any NodeProtocol] {
        [parenthesisLeft, expression, parenthesisRight]
    }

    public let parenthesisLeft: TokenNode
    public let expression: any NodeProtocol
    public let parenthesisRight: TokenNode

    // MARK: - Initializer

    public init(parenthesisLeft: TokenNode, expression: any NodeProtocol, parenthesisRight: TokenNode) {
        self.parenthesisLeft = parenthesisLeft
        self.expression = expression
        self.parenthesisRight = parenthesisRight
    }
}
