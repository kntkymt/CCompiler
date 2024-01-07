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
    var kind: NodeKind { get }
    var sourceTokens: [Token] { get }
    var children: [any NodeProtocol] { get }
}

extension NodeProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnyNode(lhs) == AnyNode(rhs)
    }
}

public final class AnyNode: NodeProtocol {

    public let kind: NodeKind
    public let sourceTokens: [Token]
    public let children: [any NodeProtocol]

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
