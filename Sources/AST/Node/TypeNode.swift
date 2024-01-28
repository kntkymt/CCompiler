import Tokenizer

public protocol TypeNodeProtocol: NodeProtocol {

    var memorySize: Int { get }
}

public class TypeNode: TypeNodeProtocol {

    public enum TypeKind {
        case int
        case char
    }

    // MARK: - Property

    public let kind: NodeKind = .type
    public var children: [any NodeProtocol] = []
    public let sourceRange: SourceRange

    public let type: TypeKind

    public var memorySize: Int {
        return switch type {
        case .int: 8
        case .char: 1
        }
    }

    // MARK: - Initializer

    public init(type: TypeKind, sourceRange: SourceRange) {
        self.type = type
        self.sourceRange = sourceRange
    }
}

public class PointerTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .pointerType
    public var children: [any NodeProtocol] {
        [referenceType]
    }
    public let sourceRange: SourceRange

    public let referenceType: any TypeNodeProtocol

    public let memorySize: Int = 8

    // MARK: - Initializer

    public init(referenceType: any TypeNodeProtocol, sourceRange: SourceRange) {
        self.referenceType = referenceType
        self.sourceRange = sourceRange
    }
}

public class ArrayTypeNode: TypeNodeProtocol {

    // MARK: - Property

    public let kind: NodeKind = .arrayType
    public var children: [any NodeProtocol] {
        [elementType]
    }
    public let sourceRange: SourceRange

    public let elementType: any TypeNodeProtocol
    public let arrayLength: Int

    public var memorySize: Int {
        arrayLength * elementType.memorySize
    }

    // MARK: - Initializer

    public init(elementType: any TypeNodeProtocol, arrayLength: Int, sourceRange: SourceRange) {
        self.elementType = elementType
        self.arrayLength = arrayLength
        self.sourceRange = sourceRange
    }
}
