import Tokenizer

public final class Node: Equatable {

    // MARK: - Property

    public let kind: NodeKind

    public let left: Node?
    public let right: Node?

    public let token: Token

    // MARK: - Initializer

    public init(kind: NodeKind, left: Node?, right: Node?, token: Token) {
        self.kind = kind
        self.left = left
        self.right = right
        self.token = token
    }

    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.kind == rhs.kind && lhs.left == rhs.left && lhs.right == rhs.right && lhs.token == rhs.token
    }
}

public enum NodeKind: Equatable {
    /// `+`
    case add

    /// `-`
    case sub

    /// `*`
    case mul

    /// `/`
    case div

    /// integer e.g. 1, 123
    case number

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
