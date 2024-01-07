import Tokenizer

public protocol TypeNodeProtocol: NodeProtocol {

    var memorySize: Int { get }
}

public class TypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .type
    public var sourceTokens: [Token] { [typeToken] }
    public let children: [any NodeProtocol] = []

    public let typeToken: Token

    public var memorySize: Int {
        return switch typeToken {
        case .type(let typeKind, _):
            switch typeKind {
            case .int: 8
            case .char: 1
            }

        default:
            fatalError()
        }
    }

    // MARK: - Initializer

    public init(typeToken: Token) {
        self.typeToken = typeToken
    }
}

public class PointerTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .pointerType
    public var sourceTokens: [Token] { referenceType.sourceTokens + [pointerToken] }
    public var children: [any NodeProtocol] { [referenceType] }
    public let referenceType: any TypeNodeProtocol

    public let pointerToken: Token

    public let memorySize: Int = 8

    // MARK: - Initializer

    public init(referenceType: any TypeNodeProtocol, pointerToken: Token) {
        self.referenceType = referenceType
        self.pointerToken = pointerToken
    }
}

public class ArrayTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .arrayType

    public var sourceTokens: [Token] { [squareLeftToken] + elementType.sourceTokens + [squareRightToken] }
    public var children: [any NodeProtocol] { [elementType] }
    public let elementType: any TypeNodeProtocol

    public let squareLeftToken: Token
    public let arraySizeToken: Token
    public let squareRightToken: Token

    public var arraySize: Int {
        Int(arraySizeToken.value)!
    }

    public var memorySize: Int {
        arraySize * elementType.memorySize
    }
    // MARK: - Initializer

    public init(elementType: any TypeNodeProtocol, squareLeftToken: Token, arraySizeToken: Token, squareRightToken: Token) {
        self.elementType = elementType
        self.squareLeftToken = squareLeftToken
        self.arraySizeToken = arraySizeToken
        self.squareRightToken = squareRightToken
    }
}
