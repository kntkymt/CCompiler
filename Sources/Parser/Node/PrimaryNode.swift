import Tokenizer

public class TokenNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .token
    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any NodeProtocol] = []
    
    public let token: Token

    public var tokenKind: TokenKind {
        token.kind
    }
    public var text: String {
        token.text
    }
    public var description: String {
        token.description
    }

    // MARK: - Initializer

    public init(token: Token) {
        self.token = token
    }
}

public class IntegerLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .integerLiteral
    public var children: [any NodeProtocol] {
        [literal]
    }

    public let literal: TokenNode

    // MARK: - Initializer

    public init(literal: TokenNode) {
        self.literal = literal
    }
}

public class StringLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .stringLiteral
    public var children: [any NodeProtocol] {
        [literal]
    }

    public let literal: TokenNode

    // MARK: - Initializer

    public init(literal: TokenNode) {
        self.literal = literal
    }
}

public class IdentifierNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .identifier
    public var children: [any NodeProtocol] {
        [baseName]
    }

    public let baseName: TokenNode

    // MARK: - Initializer

    public init(baseName: TokenNode) {
        self.baseName = baseName
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
        switch `operator`.tokenKind {
        case .reserved(.add):
            return .add

        case .reserved(.sub):
            return .sub

        case .reserved(.mul):
            return .mul

        case .reserved(.div):
            return .div

        case .reserved(.equal):
            return .equal

        case .reserved(.notEqual):
            return .notEqual

        case .reserved(.lessThan):
            return .lessThan

        case .reserved(.lessThanOrEqual):
            return .lessThanOrEqual

        case .reserved(.greaterThan):
            return .greaterThan

        case .reserved(.greaterThanOrEqual):
            return .greaterThanOrEqual

        default:
            fatalError()
        }
    }
    public var children: [any NodeProtocol] {
        [`operator`]
    }

    public let `operator`: TokenNode

    // MARK: - Initializer

    public init(operator: TokenNode) {
        self.operator = `operator`
    }
}

public class AssignNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .assign
    public var children: [any NodeProtocol] {
        [equal]
    }

    public let equal: TokenNode

    // MARK: - Initializer

    public init(equal: TokenNode) {
        self.equal = equal
    }
}
