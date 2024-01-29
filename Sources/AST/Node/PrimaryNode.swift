import Tokenizer

public class IntegerLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .integerLiteral
    public var children: [any NodeProtocol] = []
    public let sourceRange: SourceRange

    public let literal: String

    // MARK: - Initializer

    public init(literal: String, sourceRange: SourceRange) {
        self.literal = literal
        self.sourceRange = sourceRange
    }
}

public class StringLiteralNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .stringLiteral
    public var children: [any NodeProtocol] = []
    public let sourceRange: SourceRange

    public let literal: String

    // MARK: - Initializer

    public init(literal: String, sourceRange: SourceRange) {
        self.literal = literal
        self.sourceRange = sourceRange
    }
}

// TODO: 型情報を持つ
public class DeclReferenceNode: NodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .declReference
    public var children: [any NodeProtocol] = []
    public let sourceRange: SourceRange

    public let baseName: String

    // MARK: - Initializer

    public init(baseName: String, sourceRange: SourceRange) {
        self.baseName = baseName
        self.sourceRange = sourceRange
    }
}
