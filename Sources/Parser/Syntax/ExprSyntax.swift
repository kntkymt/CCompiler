import Tokenizer

public class InfixOperatorExprSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .infixOperatorExpr
    public var children: [any SyntaxProtocol] {
        [left, `operator`, right]
    }

    public let left: any SyntaxProtocol
    public let `operator`: TokenSyntax
    public let right: any SyntaxProtocol

    // MARK: - Initializer

    public init(left: any SyntaxProtocol, operator: TokenSyntax, right: any SyntaxProtocol) {
        self.left = left
        self.operator = `operator`
        self.right = right
    }
}

public class PrefixOperatorExprSyntax: SyntaxProtocol {

    public enum OperatorKind {
        /// `+`
        case plus

        /// `-`
        case minus

        /// `*`
        case reference

        /// `&`
        case address

        /// `sizeof`
        case sizeof
    }

    // MARK: - Property

    public let kind: SyntaxKind = .prefixOperatorExpr
    public var children: [any SyntaxProtocol] {
        [`operator`, expression]
    }

    public let `operator`: TokenSyntax
    public let expression: any SyntaxProtocol

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

        case .keyword(.sizeof):
            return .sizeof

        default:
            fatalError()
        }
    }

    // MARK: - Initializer

    public init(operator: TokenSyntax, expression: any SyntaxProtocol) {
        self.operator = `operator`
        self.expression = expression
    }
}

public class FunctionCallExprSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .functionCallExpr
    public var children: [any SyntaxProtocol] {
        [identifier, parenthesisLeft] + arguments + [parenthesisRight]
    }

    public let identifier: DeclReferenceSyntax
    public let parenthesisLeft: TokenSyntax
    public let arguments: [ExprListItemSyntax]
    public let parenthesisRight: TokenSyntax

    // MARK: - Initializer

    public init(identifier: DeclReferenceSyntax, parenthesisLeft: TokenSyntax, arguments: [ExprListItemSyntax], parenthesisRight: TokenSyntax) {
        self.identifier = identifier
        self.parenthesisLeft = parenthesisLeft
        self.arguments = arguments
        self.parenthesisRight = parenthesisRight
    }
}

public class SubscriptCallExprSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .subscriptCallExpr
    public var children: [any SyntaxProtocol] {
        [identifier, squareLeft, argument, squareRight]
    }

    public let identifier: DeclReferenceSyntax
    public let squareLeft: TokenSyntax
    public let argument: any SyntaxProtocol
    public let squareRight: TokenSyntax

    // MARK: - Initializer

    public init(identifier: DeclReferenceSyntax, squareLeft: TokenSyntax, argument: any SyntaxProtocol, squareRight: TokenSyntax) {
        self.identifier = identifier
        self.squareLeft = squareLeft
        self.argument = argument
        self.squareRight = squareRight
    }
}

public class InitListExprSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .initListExpr
    public var children: [any SyntaxProtocol] {
        [braceLeft] + exprListItemSyntaxs + [braceRight]
    }

    public let braceLeft: TokenSyntax
    public let exprListItemSyntaxs: [ExprListItemSyntax]
    public let braceRight: TokenSyntax

    // MARK: - Initializer

    public init(braceLeft: TokenSyntax, exprListSyntaxs: [ExprListItemSyntax], braceRight: TokenSyntax) {
        self.braceLeft = braceLeft
        self.exprListItemSyntaxs = exprListSyntaxs
        self.braceRight = braceRight
    }
}

public class ExprListItemSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .exprListItem
    public var children: [any SyntaxProtocol] {
        ([expression, comma] as [(any SyntaxProtocol)?]).compactMap { $0 }
    }

    public let expression: any SyntaxProtocol
    public let comma: TokenSyntax?

    // MARK: - Initializer

    public init(expression: any SyntaxProtocol, comma: TokenSyntax? = nil) {
        self.expression = expression
        self.comma = comma
    }
}

public class TupleExprSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .tupleExpr
    public var children: [any SyntaxProtocol] {
        [parenthesisLeft, expression, parenthesisRight]
    }

    public let parenthesisLeft: TokenSyntax
    public let expression: any SyntaxProtocol
    public let parenthesisRight: TokenSyntax

    // MARK: - Initializer

    public init(parenthesisLeft: TokenSyntax, expression: any SyntaxProtocol, parenthesisRight: TokenSyntax) {
        self.parenthesisLeft = parenthesisLeft
        self.expression = expression
        self.parenthesisRight = parenthesisRight
    }
}
