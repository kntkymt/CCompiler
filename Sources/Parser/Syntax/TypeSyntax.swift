import Tokenizer

public protocol TypeSyntaxProtocol: SyntaxProtocol {
}

public class TypeSyntax: TypeSyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .type
    public var children: [any SyntaxProtocol] {
        [type]
    }

    public let type: TokenSyntax

    // MARK: - Initializer

    public init(type: TokenSyntax) {
        self.type = type
    }
}

public class PointerTypeSyntax: TypeSyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .pointerType
    public var children: [any SyntaxProtocol] {
        [referenceType, pointer]
    }

    public let referenceType: any TypeSyntaxProtocol
    public let pointer: TokenSyntax

    // MARK: - Initializer

    public init(referenceType: any TypeSyntaxProtocol, pointer: TokenSyntax) {
        self.referenceType = referenceType
        self.pointer = pointer
    }
}
