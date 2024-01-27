import Tokenizer

public enum SyntaxKind {
    case token

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
    case exprListItem
    case tupleExpr

    case ifStatement
    case whileStatement
    case forStatement
    case returnStatement
    case blockStatement
    case blockItem

    case functionDecl
    case functionParameter
    case variableDecl

    case sourceFile
}

public protocol SyntaxProtocol: Equatable {
    var kind: SyntaxKind { get }
    var sourceTokens: [Token] { get }
    var children: [any SyntaxProtocol] { get }
}

public extension SyntaxProtocol {
    var sourceTokens: [Token] {
        children.flatMap { $0.sourceTokens }
    }
}

extension SyntaxProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnySyntax(lhs) == AnySyntax(rhs)
    }
}

public final class AnySyntax: SyntaxProtocol {

    public let kind: SyntaxKind
    public let sourceTokens: [Token]
    public let children: [any SyntaxProtocol]

    public init(_ syntax: any SyntaxProtocol) {
        self.sourceTokens = syntax.sourceTokens
        self.children = syntax.children
        self.kind = syntax.kind
    }

    public static func == (lhs: AnySyntax, rhs: AnySyntax) -> Bool {
        lhs.kind == rhs.kind 
        && lhs.sourceTokens == rhs.sourceTokens
        && lhs.children.count == rhs.children.count
        && zip(lhs.children, rhs.children).allSatisfy { lhsChild, rhsChild in
            AnySyntax(lhsChild) == AnySyntax(rhsChild)
        }
    }
}
