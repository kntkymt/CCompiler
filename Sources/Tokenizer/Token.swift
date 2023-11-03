public struct Token: Equatable {

    // MARK: - Property

    public var kind: Kind
    public var sourceIndex: Int

    public var value: String {
        switch kind {
        case .reserved(let kind):
            return kind.rawValue

        case .number(let value):
            return value
        }
    }

    // MARK: - Initializer

    public init(kind: Kind, sourceIndex: Int) {
        self.kind = kind
        self.sourceIndex = sourceIndex
    }

    public enum Kind: Equatable {

        case reserved(ReservedKind)
        case number(String)

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
        }
    }
}
