public enum Token: Equatable {

    // MARK: - Property

    case reserved(_ kind: ReservedKind, sourceIndex: Int)
    case number(_ value: String, sourceIndex: Int)
    case identifier(_ value: Character, sourceIndex: Int)

    public var value: String {
        switch self {
        case .reserved(let kind, _):
            return kind.rawValue

        case .number(let value, _):
            return value

        case .identifier(let value, _):
            return String(value)
        }
    }

    public var sourceIndex: Int {
        switch self {
        case .reserved(_, let sourceIndex):
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
    }
}
