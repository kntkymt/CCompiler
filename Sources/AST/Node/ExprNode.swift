import Tokenizer

public class InfixOperatorExprNode: NodeProtocol {

    public enum OperatorKind: String {
        /// `+`
        case add = "+"

        /// `-`
        case sub = "-"

        /// `*`
        case mul = "*"

        /// `/`
        case div = "/"

        /// `==`
        case equal = "=="

        /// `!=`
        case notEqual = "!="

        /// `<`
        case lessThan = "<"

        /// `<=`
        case lessThanOrEqual = "<="

        /// `>`
        case greaterThan = ">"

        /// `>=`
        case greaterThanOrEqual = ">="

        /// `=`
        case assign = "="
    }

    // MARK: - Property

    public let kind: NodeKind = .infixOperatorExpr
    public var children: [any NodeProtocol] {
        [left, right]
    }
    public let sourceRange: SourceRange

    public let left: any NodeProtocol
    public let `operator`: OperatorKind
    public let right: any NodeProtocol

    // MARK: - Initializer

    public init(left: any NodeProtocol, operator: OperatorKind, right: any NodeProtocol, sourceRange: SourceRange) {
        self.left = left
        self.operator = `operator`
        self.right = right
        self.sourceRange = sourceRange
    }
}

public class PrefixOperatorExprNode: NodeProtocol {

    public enum OperatorKind: String {
        /// `+`
        case plus = "+"

        /// `-`
        case minus = "-"

        /// `*`
        case reference = "*"

        /// `&`
        case address = "&"

        /// `sizeof`
        case sizeof = "sizeof"
    }

    // MARK: - Property

    public let kind: NodeKind = .prefixOperatorExpr
    public var children: [any NodeProtocol] {
        [expression]
    }
    public let sourceRange: SourceRange

    public let `operator`: OperatorKind
    public let expression: any NodeProtocol

    // MARK: - Initializer

    public init(operator: OperatorKind, expression: any NodeProtocol, sourceRange: SourceRange) {
        self.operator = `operator`
        self.expression = expression
        self.sourceRange = sourceRange
    }
}

public class FunctionCallExprNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .functionCallExpr
    public var children: [any NodeProtocol] {
        [identifier] + arguments
    }
    public let sourceRange: SourceRange

    public let identifier: DeclReferenceNode
    public let arguments: [any NodeProtocol]

    // MARK: - Initializer

    public init(identifier: DeclReferenceNode, arguments: [any NodeProtocol], sourceRange: SourceRange) {
        self.identifier = identifier
        self.arguments = arguments
        self.sourceRange = sourceRange
    }
}

public class SubscriptCallExprNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .subscriptCallExpr
    public var children: [any NodeProtocol] {
        [identifier, argument]
    }
    public let sourceRange: SourceRange

    public let identifier: DeclReferenceNode
    public let argument: any NodeProtocol

    // MARK: - Initializer

    public init(identifier: DeclReferenceNode, argument: any NodeProtocol, sourceRange: SourceRange) {
        self.identifier = identifier
        self.argument = argument
        self.sourceRange = sourceRange
    }
}

public class InitListExprNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .initListExpr
    public var children: [any NodeProtocol] {
        expressions
    }
    public let sourceRange: SourceRange

    public let expressions: [any NodeProtocol]

    // MARK: - Initializer

    public init(expressions: [any NodeProtocol], sourceRange: SourceRange) {
        self.expressions = expressions
        self.sourceRange = sourceRange
    }
}

public class TupleExprNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .tupleExpr
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
