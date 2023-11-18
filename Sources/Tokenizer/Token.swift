public enum Token: Equatable {

    // MARK: - Property

    case reserved(_ kind: ReservedKind, sourceIndex: Int)
    case keyword(_ kind: KeywordKind, sourceIndex: Int)
    case number(_ value: String, sourceIndex: Int)
    case identifier(_ value: String, sourceIndex: Int)

    public var value: String {
        switch self {
        case .reserved(let kind, _):
            return kind.rawValue

        case .keyword(let kind, _):
            return kind.rawValue

        case .number(let value, _):
            return value

        case .identifier(let value, _):
            return value
        }
    }

    public var sourceIndex: Int {
        switch self {
        case .reserved(_, let sourceIndex):
            return sourceIndex

        case .keyword(_, let sourceIndex):
            return sourceIndex

        case .number(_, let sourceIndex):
            return sourceIndex

        case .identifier(_, let sourceIndex):
            return sourceIndex
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

        /// `(`
        case parenthesisLeft = "("

        /// `)`
        case parenthesisRight = ")"

        /// `{`
        case braceLeft = "{"

        /// `}`
        case braceRight = "}"

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
    }
}
