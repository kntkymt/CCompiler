public enum TokenizeError: Error, Equatable {
    case unknownToken(index: Int)
}

public func tokenize(_ source: String) throws -> [Token] {
    var tokens: [Token] = []

    let charactors = [Character](source)
    var index = 0

    func extractNumber() -> Token {
        var token = ""
        let startIndex = index

        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isNumber {
                token += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return Token(kind: .number, value: token, sourceIndex: startIndex)
    }

    while index < charactors.count {
        if charactors[index].isWhitespace {
            index += 1
            continue
        }

        if charactors[index] == "+" {
            tokens.append(Token(kind: .add, value: "+", sourceIndex: index))
            index += 1
            continue
        }

        if charactors[index] == "-" {
            tokens.append(Token(kind: .sub, value: "-", sourceIndex: index))
            index += 1
            continue
        }

        if charactors[index].isNumber {
            tokens.append(extractNumber())
            continue
        }

        throw TokenizeError.unknownToken(index: index)
    }

    return tokens
}
