import Tokenizer

public class TokenSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .token
    public var sourceTokens: [Token] {
        [token]
    }
    public let children: [any SyntaxProtocol] = []
    
    public let token: Token

    public var tokenKind: TokenKind {
        token.kind
    }
    
    public var text: String {
        token.text
    }
        
    public var description: String {    
        token.description
    }

    // MARK: - Initializer

    public init(token: Token) {
        self.token = token
    }
}

public class IntegerLiteralSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .integerLiteral
    public var children: [any SyntaxProtocol] {
        [literal]
    }

    public let literal: TokenSyntax

    // MARK: - Initializer

    public init(literal: TokenSyntax) {
        self.literal = literal
    }
}

public class StringLiteralSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .stringLiteral
    public var children: [any SyntaxProtocol] {
        [literal]
    }

    public let literal: TokenSyntax

    // MARK: - Initializer

    public init(literal: TokenSyntax) {
        self.literal = literal
    }
}

public class DeclReferenceSyntax: SyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .declReference
    public var children: [any SyntaxProtocol] {
        [baseName]
    }

    public let baseName: TokenSyntax

    // MARK: - Initializer

    public init(baseName: TokenSyntax) {
        self.baseName = baseName
    }
}
