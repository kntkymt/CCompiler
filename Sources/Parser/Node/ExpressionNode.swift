import Tokenizer

public class InfixOperatorExpressionNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .infixOperatorExpr

    public var left: any NodeProtocol
    public var right: any NodeProtocol

    public var `operator`: any NodeProtocol

    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { [left, right, `operator`] }

    // MARK: - Initializer

    init(operator: any NodeProtocol, left: any NodeProtocol, right: any NodeProtocol, sourceTokens: [Token]) {
        self.operator = `operator`
        self.left = left
        self.right = right
        self.sourceTokens = sourceTokens
    }
}

public class PrefixOperatorExpressionNode: NodeProtocol {

    public enum OperatorKind {
        /// `*`
        case reference

        /// `&`
        case address
    }

    // MARK: - Property

    public var kind: NodeKind = .prefixOperatorExpr

    public var operatorKind: OperatorKind {
        switch `operator` {
        case .reserved(.mul, _):
            return .reference

        case .reserved(.and, _):
            return .address

        default:
            fatalError()
        }
    }

    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { [right] }
    public let `operator`: Token

    public let right: any NodeProtocol

    // MARK: - Initializer

    init(operator: Token, right: any NodeProtocol, sourceTokens: [Token]) {
        self.operator = `operator`
        self.right = right
        self.sourceTokens = sourceTokens
    }
}

public class FunctionCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .functionCallExpr
    public let sourceTokens: [Token]
    public var children: [any NodeProtocol] { arguments }

    public let token: Token
    public let arguments: [any NodeProtocol]
    public var functionName: String {
        token.value
    }

    // MARK: - Initializer

    init(token: Token, arguments: [any NodeProtocol], sourceTokens: [Token]) {
        self.token = token
        self.arguments = arguments
        self.sourceTokens = sourceTokens
    }
}

public class SubscriptCallExpressionNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .subscriptCallExpr
    public var sourceTokens: [Token] { [identifierToken, squareLeftToken] + argument.sourceTokens + [squareRightToken] }
    public var children: [any NodeProtocol] { [argument] }

    public let identifierToken: Token
    public let squareLeftToken: Token
    public let argument: any NodeProtocol
    public let squareRightToken: Token

    // MARK: - Initializer

    public init(identifierToken: Token, squareLeftToken: Token, argument: any NodeProtocol, squareRightToken: Token) {
        self.identifierToken = identifierToken
        self.squareLeftToken = squareLeftToken
        self.argument = argument
        self.squareRightToken = squareRightToken
    }
}
