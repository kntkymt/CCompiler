enum CompileError: Error {
    case invalidSyntax
}

public func compile(_ source: String) throws -> String {
    var compiled = ".globl _main\n"

    compiled += "_main:\n"

    let tokens = try tokenize(source)
    var index = 0

    @discardableResult
    func consumeToken(_ tokenKind: TokenKind) throws -> Token {
        if index < tokens.count, tokens[index].kind == tokenKind {
            let token = tokens[index]
            index += 1
            return token
        } else {
            throw CompileError.invalidSyntax
        }
    }

    // 最初は数字
    let firstInt = try consumeToken(.number)
    compiled += "    mov w0, #\(firstInt.value)\n"

    while index < tokens.count {
        switch tokens[index].kind {
        case .add:
            try consumeToken(.add)

            let int = try consumeToken(.number)
            compiled += "    add w0, w0, #\(int.value)\n"

        case .sub:
            try consumeToken(.sub)

            let int = try consumeToken(.number)
            compiled += "    sub w0, w0, #\(int.value)\n"

        default:
            throw CompileError.invalidSyntax
        }
    }

    compiled += "    ret\n"

    return compiled
}
