import Tokenizer

public protocol TypeSyntaxProtocol: SyntaxProtocol {

    var memorySize: Int { get }
}

public class TypeSyntax: TypeSyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .type
    public var children: [any SyntaxProtocol] {
        [type]
    }

    public let type: TokenSyntax

    public var memorySize: Int {
        return switch type.tokenKind {
        case .type(let typeKind):
            switch typeKind {
            case .int: 8
            case .char: 1
            }

        default:
            fatalError()
        }
    }

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

    public let memorySize: Int = 8

    // MARK: - Initializer

    public init(referenceType: any TypeSyntaxProtocol, pointer: TokenSyntax) {
        self.referenceType = referenceType
        self.pointer = pointer
    }
}

public class ArrayTypeSyntax: TypeSyntaxProtocol {

    // MARK: - Property

    public let kind: SyntaxKind = .arrayType
    public var children: [any SyntaxProtocol] {
        [elementType, squareLeft, arraySize, squareRight]
    }

    public let elementType: any TypeSyntaxProtocol
    public let squareLeft: TokenSyntax
    public let arraySize: TokenSyntax
    public let squareRight: TokenSyntax

    public var arrayLength: Int {
        Int(arraySize.text)!
    }

    public var memorySize: Int {
        arrayLength * elementType.memorySize
    }
    // MARK: - Initializer

    public init(elementType: any TypeSyntaxProtocol, squareLeft: TokenSyntax, arraySize: TokenSyntax, squareRight: TokenSyntax) {
        self.elementType = elementType
        self.squareLeft = squareLeft
        self.arraySize = arraySize
        self.squareRight = squareRight
    }
}
