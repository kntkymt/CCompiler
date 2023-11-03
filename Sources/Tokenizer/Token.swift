public struct Token: Equatable {

    // MARK: - Property
    
    public var kind: TokenKind
    public var value: String

    public var sourceIndex: Int

    // MARK: - Initializer

    public init(kind: TokenKind, value: String, sourceIndex: Int) {
        self.kind = kind
        self.value = value
        self.sourceIndex = sourceIndex
    }
}

public enum TokenKind {
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

    /// `(`
    case parenthesisLeft

    /// `)`
    case parenthesisRight

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
