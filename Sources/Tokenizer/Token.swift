public struct Token: Equatable {

    // MARK: - Property

    public let kind: TokenKind
    public let leadingTrivia: String
    public let trailingTrivia: String
    public let sourceIndex: Int

    /// without trivia
    public var value: String {
        kind.value
    }

    /// with trivia
    public var description: String {
        leadingTrivia + kind.value + trailingTrivia
    }

    // MARK: - Initializer

    public init(kind: TokenKind, leadingTrivia: String = "", trailingTrivia: String = "", sourceIndex: Int) {
        self.kind = kind
        self.leadingTrivia = leadingTrivia
        self.trailingTrivia = trailingTrivia
        self.sourceIndex = sourceIndex
    }
}

public enum TokenKind: Equatable {

    // MARK: - Property

    case reserved(_ kind: ReservedKind)
    case keyword(_ kind: KeywordKind)
    case number(_ value: String)
    case stringLiteral(_ value: String)
    case identifier(_ value: String)
    case type(_ kind: TypeKind)

    public var value: String {
        switch self {
        case .reserved(let kind):
            return kind.rawValue

        case .keyword(let kind):
            return kind.rawValue

        case .number(let value):
            return value

        case .stringLiteral(let value):
            return value

        case .identifier(let value):
            return value

        case .type(let kind):
            return kind.rawValue
        }
    }

    public enum ReservedKind: String, CaseIterable {
        /// `+`
        case add = "+"

        /// `-`
        case sub = "-"

        /// `*`
        case mul = "*"

        /// `/`
        case div = "/"

        /// `&`
        case and = "&"

        /// `(`
        case parenthesisLeft = "("

        /// `)`
        case parenthesisRight = ")"

        /// `{`
        case braceLeft = "{"

        /// `}`
        case braceRight = "}"

        /// `[`
        case squareLeft = "["

        /// `]`
        case squareRight = "]"

        /// `==`
        case equal = "=="

        /// `!=`
        case notEqual = "!="

        /// `<`
        case lessThan = "<"

        /// `<=`
        case lessThanOrEqual = "<="

        /// `>`
        case greaterThan = ">"

        /// `>=`
        case greaterThanOrEqual = ">="

        /// `=`
        case assign = "="

        /// `;`
        case semicolon = ";"

        /// `,`
        case comma = ","
    }

    public enum KeywordKind: String, CaseIterable {
        case `return`
        case `if`
        case `else`
        case `while`
        case `for`

        case sizeof
    }

    public enum TypeKind: String, CaseIterable {
        case int
        case char
    }
}
