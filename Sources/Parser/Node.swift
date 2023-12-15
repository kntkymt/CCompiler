import Tokenizer

public enum NodeKind {
    case integerLiteral
    case identifier

    case type
    case pointerType
    case arrayType

    case binaryOperator
    case assign

    case prefixOperatorExpr
    case infixOperatorExpr
    case functionCallExpr

    case ifStatement
    case whileStatement
    case forStatement
    case returnStatement
    case blockStatement

    case functionDecl
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

public class TypeNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .type
    public var sourceTokens: [Token] { [typeToken] }
    public let children: [any NodeProtocol] = []

    public let typeToken: Token

    // MARK: - Initializer

    public init(typeToken: Token) {
        self.typeToken = typeToken
    }
}

public class PointerTypeNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .pointerType
    public var sourceTokens: [Token] { referenceType.sourceTokens + [pointerToken] }
    public var children: [any NodeProtocol] { [referenceType] }
    public let referenceType: any NodeProtocol

    public let pointerToken: Token

    // MARK: - Initializer

    init(referenceType: any NodeProtocol, pointerToken: Token) {
        self.referenceType = referenceType
        self.pointerToken = pointerToken
    }
}

public class ArrayTypeNode: NodeProtocol {

    // MARK: - Property

    public var kind: NodeKind = .arrayType

    public var sourceTokens: [Token] { [squareLeftToken] + elementType.sourceTokens + [squareRightToken] }
    public var children: [any NodeProtocol] { [elementType] }
    public let elementType: any NodeProtocol

    public let squareLeftToken: Token
    public let arraySizeToken: Token
    public let squareRightToken: Token

    public init(elementType: any NodeProtocol, squareLeftToken: Token, arraySizeToken: Token, squareRightToken: Token) {
        self.elementType = elementType
        self.squareLeftToken = squareLeftToken
        self.arraySizeToken = arraySizeToken
        self.squareRightToken = squareRightToken
    }
}
