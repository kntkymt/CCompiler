public struct Token: Equatable {
    public var kind: TokenKind
    public var value: String
}

public enum TokenKind {
    case add
    case sub
    case number
}
