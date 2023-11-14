import Tokenizer

public final class Node: Equatable {

    // MARK: - Property

    public let kind: NodeKind

    public var left: Node?
    public var right: Node?

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

    /// assign to var e.g: a = 10
    case assign

    /// local variable
    case localVariable

    /// return statement
    case `return`

    /// while statement
    case `while`

    /// if statement
    case `if`

    /// if else statement
    case `else`

    /// for statement start
    case `for`

    /// for statement condintion
    case forCondition

    /// for body
    case forBody
}
