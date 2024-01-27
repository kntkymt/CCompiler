import Tokenizer

extension Parser {
    func at(_ spec: TokenSpec) -> Bool {
        return spec ~= tokens[index]
    }

    func at(_ specs: TokenSpec...) -> Bool {
        for spec in specs where at(spec) {
            return true
        }

        return false
    }

    func consume(if spec: TokenSpec) -> TokenNode? {
        return try? consume(spec)
    }

    func consume(if specs: TokenSpec...) -> TokenNode? {
        for spec in specs {
            if let token = consume(if: spec) {
                return token
            }
        }

        return nil
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

    func consume(_ specs: TokenSpec...) throws -> TokenNode {
        for spec in specs where at(spec) {
            let token = tokens[index]
            index += 1
            return TokenNode(token: token)
        }

        throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
    }
}
