public struct Token: Equatable {

    // MARK: - Property

    public var kind: TokenKind
    public var leadingTrivia: String
    public var trailingTrivia: String
    public var sourceRange: SourceRange

    /// without trivia
    public var text: String {
        kind.text
    }

    /// with trivia
    public var description: String {
        leadingTrivia + kind.text + trailingTrivia
    }

    // MARK: - Initializer

    public init(kind: TokenKind, leadingTrivia: String = "", trailingTrivia: String = "", sourceRange: SourceRange) {
        self.kind = kind
        self.leadingTrivia = leadingTrivia
        self.trailingTrivia = trailingTrivia
        self.sourceRange = sourceRange
    }
}

public struct SourceRange: Equatable {

    // MARK: - Property

    public var start: SourceLocation
    public var end: SourceLocation

    // MARK: - Initializer

    public init(start: SourceLocation, end: SourceLocation) {
        self.start = start
        self.end = end
    }
}

public struct SourceLocation: Equatable {

    // MARK: - Property

    public var line: Int
    public var column: Int

    // MARK: - Initializer

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

extension SourceLocation {
    public static let startOfFile = SourceLocation(line: 1, column: 1)
}

public enum TokenKind: Equatable {

    // MARK: - Property

    case reserved(_ kind: ReservedKind)
    case keyword(_ kind: KeywordKind)
    case number(_ value: String)
    case stringLiteral(_ value: String)
    case identifier(_ value: String)
    case type(_ kind: TypeKind)

    public var text: String {
        switch self {
        case .reserved(let kind):
            return kind.rawValue

        case .keyword(let kind):
            return kind.rawValue

        case .number(let value):
            return value

        case .stringLiteral(let value):
            return "\"" + value + "\""

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
