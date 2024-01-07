import Tokenizer

public class IntegerLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .integerLiteral

    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []
    public let token: Token

    public var literal: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
    }
}

public class StringLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .stringLiteral
    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []

    public let token: Token

    public var value: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
    }
}

public class IdentifierNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .identifier

    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []
    public let token: Token

    public var identifierName: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
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

    public let kind: NodeKind = .binaryOperator

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
    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []
    public let token: Token

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
    }
}

public class AssignNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .assign

    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []
    public let token: Token

    // MARK: - Initializer

    init(token: Token) {
        self.token = token
    }
}
