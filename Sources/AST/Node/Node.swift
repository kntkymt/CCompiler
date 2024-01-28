import Tokenizer

public enum NodeKind {
    case integerLiteral
    case declReference
    case stringLiteral

    case type
    case pointerType
    case arrayType

    case prefixOperatorExpr
    case infixOperatorExpr
    case functionCallExpr
    case subscriptCallExpr
    case initListExpr
    case tupleExpr

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
    var children: [any NodeProtocol] { get }

    var sourceRange: SourceRange { get }
}

extension NodeProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnyNode(lhs) == AnyNode(rhs)
    }
}


public final class AnyNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind
    public let children: [any NodeProtocol]
    public let sourceRange: SourceRange

    // MARK: - Initializer

    public init(_ node: any NodeProtocol) {
        self.kind = node.kind
        self.children = node.children
        self.sourceRange = node.sourceRange
    }

    public static func == (lhs: AnyNode, rhs: AnyNode) -> Bool {
        lhs.kind == rhs.kind
        && lhs.children.count == rhs.children.count
        && zip(lhs.children, rhs.children).allSatisfy { lhsChild, rhsChild in
            AnyNode(lhsChild) == AnyNode(rhsChild)
        }
        && lhs.sourceRange == rhs.sourceRange
    }
}
