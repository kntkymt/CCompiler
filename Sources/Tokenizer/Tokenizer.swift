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

    func extractString() -> Token {
        var string = ""
        let startIndex = index

        // 開始の"
        index += 1

        while index < charactors.count {
            let nextToken = charactors[index]

            if nextToken == "\"" {
                index += 1
                break
            } else {
                string += String(nextToken)
                index += 1
            }
        }

        return .stringLiteral(string, sourceIndex: startIndex)
    }

    func extractIdentifier() -> Token {
        var string = ""
        let startIndex = index

        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isIdentifierCharactor {
                string += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return .identifier(string, sourceIndex: startIndex)
    }

    // 文字数が多い物からチェックしないといけない
    // 例: <= の時に<を先にチェックすると<, =の2つのトークンになってしまう
    let reservedKinds = Token.ReservedKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }
    let keywordKinds = Token.KeywordKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }
    let typeKinds = Token.TypeKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }

root:
    while index < charactors.count {
        if charactors[index].isWhitespace {
            index += 1
            continue
        }

        if index + 1 < charactors.count, String(charactors[index...index+1]) == "//" {
            index += 2

            while (index < charactors.count && !charactors[index].isNewline) {
                index += 1
            }

            index += 1
            continue
        }

        if index + 1 < charactors.count, String(charactors[index...index+1]) == "/*" {
            index += 2

            while (index + 1 < charactors.count && String(charactors[index...index+1]) != "*/") {
                index += 1
            }

            index += 2
            continue
        }

        if charactors[index].isNumber {
            tokens.append(extractNumber())
            continue
        }

        if charactors[index] == "\"" {
            tokens.append(extractString())
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

        for keywordKind in keywordKinds {
            let keywordString = keywordKind.rawValue
            if index + (keywordString.count - 1) < charactors.count,
               String(charactors[index..<index+keywordString.count]) == keywordString {

                // keywordの次がidentifierの文字だった場合はkeywordではなくidentifier
                if index + (keywordString.count - 1) + 1 < charactors.count,
                   charactors[index + keywordString.count].isIdentifierCharactor {
                    break
                }

                tokens.append(.keyword(keywordKind, sourceIndex: index))
                index += keywordString.count

                continue root
            }
        }

        for typeKind in typeKinds {
            let typeString = typeKind.rawValue
            if index + (typeString.count - 1) < charactors.count,
               String(charactors[index..<index+typeString.count]) == typeString {

                // typeの次がidentifierの文字だった場合はkeywordではなくidentifier
                if index + (typeString.count - 1) + 1 < charactors.count,
                   charactors[index + typeString.count].isIdentifierCharactor {
                    break
                }

                tokens.append(.type(typeKind, sourceIndex: index))
                index += typeString.count

                continue root
            }
        }

        if charactors[index].isIdentifierCharactor {
            tokens.append(extractIdentifier())
            continue
        }

        throw TokenizeError.unknownToken(index: index)
    }

    return tokens
}

private extension Character {
    var isIdentifierCharactor: Bool {
        ("a" <= self && self <= "z") || ("A" <= self && self <= "Z") || ("0" <= self && self <= "9") || self == "_"
    }
}
