import Tokenizer

public enum NodeKind {
    case integerLiteral
    case identifier
    case stringLiteral

    case type
    case pointerType
    case arrayType

    case binaryOperator
    case assign

    case prefixOperatorExpr
    case infixOperatorExpr
    case functionCallExpr
    case subscriptCallExpr
    case arrayExpr

    case ifStatement
    case whileStatement
    case forStatement
    case returnStatement
    case blockStatement

    case functionDecl
    case functionParameter
    case variableDecl

    case sourceFile
}

public protocol NodeProtocol: Equatable {
    var sourceTokens: [Token] { get }
    var children: [any NodeProtocol] { get }
    var kind: NodeKind { get }
}

extension NodeProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnyNode(lhs) == AnyNode(rhs)
    }
}

public final class AnyNode: NodeProtocol {

    public let sourceTokens: [Token]
    public let children: [any NodeProtocol]
    public let kind: NodeKind

    init(_ node: any NodeProtocol) {
        self.sourceTokens = node.sourceTokens
        self.children = node.children
        self.kind = node.kind
    }

    public static func == (lhs: AnyNode, rhs: AnyNode) -> Bool {
        lhs.kind == rhs.kind 
        && lhs.sourceTokens == rhs.sourceTokens
        && lhs.children.count == rhs.children.count
        && zip(lhs.children, rhs.children).allSatisfy { lhsChild, rhsChild in
            AnyNode(lhsChild) == AnyNode(rhsChild)
        }
    }
}

public class IntegerLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .integerLiteral

    public let sourceTokens: [Token]
    public let children: [any NodeProtocol] = []
    public var token: Token

    public var literal: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
        self.sourceTokens = [token]
    }
}

public class StringLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .stringLiteral

    public let sourceTokens: [Token]
    public let children: [any NodeProtocol] = []
    public var token: Token

    public var value: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
        self.sourceTokens = [token]
    }
}

public class IdentifierNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .identifier

    public let sourceTokens: [Token]
    public let children: [any NodeProtocol] = []
    public var token: Token

    public var identifierName: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
        self.sourceTokens = [token]
    }
}

public class BinaryOperatorNode: NodeProtocol {

    public enum OperatorKind {
        /// `+`
        case add

        /// `-`
        case sub

        /// `*`
        case mul

        /// `/`
        case div

        /// `==`
        case equal

        /// `!=`
        case notEqual

        /// `<`
        case lessThan

        /// `<=`
        case lessThanOrEqual

        /// `>`
        case greaterThan

        /// `>=`
        case greaterThanOrEqual
    }

    // MARK: - Property

    public var kind: NodeKind = .binaryOperator

    public var operatorKind: OperatorKind {
        switch token {
        case .reserved(.add, _):
            return .add

        case .reserved(.sub, _):
            return .sub

        case .reserved(.mul, _):
            return .mul

        case .reserved(.div, _):
            return .div

        case .reserved(.equal, _):
            return .equal

        case .reserved(.notEqual, _):
            return .notEqual

        case .reserved(.lessThan, _):
            return .lessThan

        case .reserved(.lessThanOrEqual, _):
            return .lessThanOrEqual

        case .reserved(.greaterThan, _):
            return .greaterThan

        case .reserved(.greaterThanOrEqual, _):
            return .greaterThanOrEqual

        default:
            fatalError()
        }
    }
    public let sourceTokens: [Token]
    public let children: [any NodeProtocol] = []
    public var token: Token

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
        self.sourceTokens = [token]
    }
}

public class AssignNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .assign

    public let sourceTokens: [Token]
    public let children: [any NodeProtocol] = []
    public var token: Token

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
        self.sourceTokens = [token]
    }
}
