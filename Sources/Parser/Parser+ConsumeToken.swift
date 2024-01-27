import Tokenizer

extension Parser {
    func at(_ spec: TokenSpec) -> Bool {
        return spec ~= tokens[index]
    }

    func consume(if spec: TokenSpec) -> TokenNode? {
        return try? consume(spec)
    }

    /// `eat` in SwiftSyntax
    func consume(_ spec: TokenSpec) throws -> TokenNode {
        if at(spec) {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        } else {
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }
}
