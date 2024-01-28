import Tokenizer

public class TokenSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .token
    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any SyntaxProtocol] = []
    
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

public class IntegerLiteralSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .integerLiteral
    public var children: [any SyntaxProtocol] {
        [literal]
    }

    public let literal: TokenSyntax

    // MARK: - Initializer

    public init(literal: TokenSyntax) {
        self.literal = literal
    }
}

public class StringLiteralSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .stringLiteral
    public var children: [any SyntaxProtocol] {
        [literal]
    }

    public let literal: TokenSyntax

    // MARK: - Initializer

    public init(literal: TokenSyntax) {
        self.literal = literal
    }
}

public class DeclReferenceSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .declReference
    public var children: [any SyntaxProtocol] {
        [baseName]
    }

    public let baseName: TokenSyntax

    // MARK: - Initializer

    public init(baseName: TokenSyntax) {
        self.baseName = baseName
    }
}

//public class BinaryOperatorSyntax: SyntaxProtocol {
//
//    public enum OperatorKind {
//        /// `+`
//        case add
//
//        /// `-`
//        case sub
//
//        /// `*`
//        case mul
//
//        /// `/`
//        case div
//
//        /// `==`
//        case equal
//
//        /// `!=`
//        case notEqual
//
//        /// `<`
//        case lessThan
//
//        /// `<=`
//        case lessThanOrEqual
//
//        /// `>`
//        case greaterThan
//
//        /// `>=`
//        case greaterThanOrEqual
//    }
//
//    // MARK: - Property
//
//    public let kind: SyntaxKind = .binaryOperator
//
//    public var operatorKind: OperatorKind {
//        switch `operator`.tokenKind {
//        case .reserved(.add):
//            return .add
//
//        case .reserved(.sub):
//            return .sub
//
//        case .reserved(.mul):
//            return .mul
//
//        case .reserved(.div):
//            return .div
//
//        case .reserved(.equal):
//            return .equal
//
//        case .reserved(.notEqual):
//            return .notEqual
//
//        case .reserved(.lessThan):
//            return .lessThan
//
//        case .reserved(.lessThanOrEqual):
//            return .lessThanOrEqual
//
//        case .reserved(.greaterThan):
//            return .greaterThan
//
//        case .reserved(.greaterThanOrEqual):
//            return .greaterThanOrEqual
//
//        default:
//            fatalError()
//        }
//    }
//    public var children: [any SyntaxProtocol] {
//        [`operator`]
//    }
//
//    public let `operator`: TokenSyntax
//
//    // MARK: - Initializer
//
//    public init(operator: TokenSyntax) {
//        self.operator = `operator`
//    }
//}
//
//public class AssignSyntax: SyntaxProtocol {
//
//    // MARK: - Property
//
//    public let kind: SyntaxKind = .assign
//    public var children: [any SyntaxProtocol] {
//        [equal]
//    }
//
//    public let equal: TokenSyntax
//
//    // MARK: - Initializer
//
//    public init(equal: TokenSyntax) {
//        self.equal = equal
//    }
//}
