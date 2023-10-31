struct Token: Equatable {
    var kind: TokenKind
    var value: String
}

enum TokenKind {
    case add
    case sub
    case number
}

enum TokenizeError: Error {
    case unknownToken
}

func tokenize(_ source: String) throws -> [Token] {
    var tokens: [Token] = []

    let charactors = [Character](source)
    var index = 0

    func extractInt() -> String {
        var token = ""
        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isNumber {
                token += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return token
    }

    while index < charactors.count {
        if charactors[index].isWhitespace {
            index += 1
            continue
        }

        if charactors[index] == "+" {
            tokens.append(Token(kind: .add, value: "+"))
            index += 1
            continue
        }

        if charactors[index] == "-" {
            tokens.append(Token(kind: .sub, value: "-"))
            index += 1
            continue
        }

        if charactors[index].isNumber {
            let numberString = extractInt()
            tokens.append(Token(kind: .number, value: numberString))
            continue
        }

        throw TokenizeError.unknownToken
    }

    return tokens
}
