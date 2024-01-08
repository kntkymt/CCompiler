import Tokenizer

public protocol TypeNodeProtocol: NodeProtocol {

    var memorySize: Int { get }
}

public class TypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .type
    public var children: [any NodeProtocol] {
        [type]
    }

    public let type: TokenNode

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

    public init(type: TokenNode) {
        self.type = type
    }
}

public class PointerTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .pointerType
    public var children: [any NodeProtocol] {
        [referenceType, pointer]
    }

    public let referenceType: any TypeNodeProtocol
    public let pointer: TokenNode

    public let memorySize: Int = 8

    // MARK: - Initializer

    public init(referenceType: any TypeNodeProtocol, pointer: TokenNode) {
        self.referenceType = referenceType
        self.pointer = pointer
    }
}

public class ArrayTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .arrayType
    public var children: [any NodeProtocol] {
        [elementType, squareLeft, arraySize, squareRight]
    }

    public let elementType: any TypeNodeProtocol
    public let squareLeft: TokenNode
    public let arraySize: TokenNode
    public let squareRight: TokenNode

    public var arrayLength: Int {
        Int(arraySize.text)!
    }

    public var memorySize: Int {
        arrayLength * elementType.memorySize
    }
    // MARK: - Initializer

    public init(elementType: any TypeNodeProtocol, squareLeft: TokenNode, arraySize: TokenNode, squareRight: TokenNode) {
        self.elementType = elementType
        self.squareLeft = squareLeft
        self.arraySize = arraySize
        self.squareRight = squareRight
    }
}
