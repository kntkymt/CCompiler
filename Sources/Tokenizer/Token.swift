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
        leadingTrivia + text + trailingTrivia
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

/// TokenKindはAssociatedValuesがあって比較に不便なため
/// AssociatedValuesを抜いたもの
public enum TokenSpec: Equatable {

    case reserved(_ kind: ReservedKind)
    case keyword(_ kind: KeywordKind)
    case integerLiteral
    case stringLiteral
    case identifier
    case type

    case endOfFile

    public static func ~= (spec: TokenSpec, token: Token) -> Bool {
        switch spec {
        case .reserved(let kind):
            if case .reserved(let tokenKind) = token.kind {
                return kind == tokenKind
            } else {
                return false
            }

        case .keyword(let kind):
            if case .keyword(let tokenKind) = token.kind {
                return kind == tokenKind
            } else {
                return false
            }

        case .integerLiteral:
            if case .integerLiteral = token.kind {
                return true
            } else {
                return false
            }

        case .stringLiteral:
            if case .stringLiteral = token.kind {
                return true
            } else {
                return false
            }

        case .identifier:
            if case .identifier = token.kind {
                return true
            } else {
                return false
            }

        case .type:
            if case .type = token.kind {
                return true
            } else {
                return false
            }

        case .endOfFile:
            return token.kind == .endOfFile
        }
    }
}

public enum TokenKind: Equatable {

    case reserved(_ kind: ReservedKind)
    case keyword(_ kind: KeywordKind)
    case integerLiteral(_ value: String)
    case stringLiteral(_ value: String)
    case identifier(_ value: String)
    case type(_ kind: TypeKind)

    case endOfFile

    // MARK: - Property

    public var text: String {
        switch self {
        case .reserved(let kind):
            return kind.rawValue

        case .keyword(let kind):
            return kind.rawValue

        case .integerLiteral(let value):
            return value

        case .stringLiteral(let value):
            return "\"" + value + "\""

        case .identifier(let value):
            return value

        case .type(let kind):
            return kind.rawValue

        case .endOfFile:
            return ""
        }
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
