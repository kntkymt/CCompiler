import Tokenizer

public enum SyntaxKind {
    case token

    case integerLiteral
    case declReference
    case stringLiteral

    case type
    case pointerType
    
    case prefixOperatorExpr
    case infixOperatorExpr
    case functionCallExpr
    case subscriptCallExpr
    case initListExpr
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

    var sourceRange: SourceRange { get }
}

public extension SyntaxProtocol {
    var sourceTokens: [Token] {
        children.flatMap { $0.sourceTokens }
    }

    var sourceRange: SourceRange {
        SourceRange(start: sourceTokens.first?.sourceRange.start ?? .startOfFile, end: sourceTokens.last?.sourceRange.end ?? .startOfFile)
    }
}

extension SyntaxProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnySyntax(lhs) == AnySyntax(rhs)
    }
}

public final class AnySyntax: SyntaxProtocol {

    public let kind: SyntaxKind
    public let children: [any SyntaxProtocol]

    public init(_ syntax: any SyntaxProtocol) {
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
        && lhs.sourceRange == rhs.sourceRange
    }
}
