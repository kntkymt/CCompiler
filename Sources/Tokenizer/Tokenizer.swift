public enum TokenizeError: Error, Equatable {
    case unknownToken(index: Int)
}

public func tokenize(source: String) throws -> [Token] {
    var tokens: [Token] = []

    let charactors = [Character](source)
    var index = 0

    func extractNumber() -> Token {
        var string = ""
        let startIndex = index

        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isNumber {
                string += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return .number(string, sourceIndex: startIndex)
    }

    // 文字数が多い物からチェックしないといけない
    // 例: <= の時に<を先にチェックすると<, =の2つのトークンになってしまう
    let reservedKinds = Token.ReservedKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }

root:
    while index < charactors.count {
        if charactors[index].isWhitespace {
            index += 1
            continue
        }

        if charactors[index].isNumber {
            tokens.append(extractNumber())
            continue
        }

        for reservedKind in reservedKinds {
            let reservedString = reservedKind.rawValue
            if index + (reservedString.count - 1) < charactors.count,
               String(charactors[index..<index+reservedString.count]) == reservedString {
                tokens.append(.reserved(reservedKind, sourceIndex: index))
                index += reservedString.count

                continue root
            }
        }

        if "a" <= charactors[index], charactors[index] <= "z" {
            tokens.append(.identifier(charactors[index], sourceIndex: index))
            index += 1
            continue
        }

        throw TokenizeError.unknownToken(index: index)
    }

    return tokens
}
