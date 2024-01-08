public enum TokenizeError: Error, Equatable {
    case unknownToken(index: Int)
}

public class Tokenizer {

    // MARK: - Property

    private let charactors: [Character]
    public var index = 0

    // MARK: - Initializer

    public init(source: String) {
        self.charactors = [Character](source)
    }

    // MARK: - Public

    public func tokenize() throws -> [Token] {
        var tokens: [Token] = []

        while index < charactors.count {
            let leadingTrivia = extractTrivia(untilBeforeNewLine: false)
            let kind = try extractTokenKind()
            let trailingTrivia = extractTrivia(untilBeforeNewLine: true)

            tokens.append(Token(kind: kind.0, leadingTrivia: leadingTrivia, trailingTrivia: trailingTrivia, sourceIndex: kind.1))
        }

        return tokens
    }

    // MARK: - Private

    private func extractNumber() -> (TokenKind, Int) {
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

        return (.number(string), startIndex)
    }

    private func extractString() -> (TokenKind, Int) {
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

        return (.stringLiteral(string), startIndex)
    }

    private func extractIdentifier() -> (TokenKind, Int) {
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

        return (.identifier(string), startIndex)
    }

    private func extractTrivia(untilBeforeNewLine: Bool) -> String {
        var result: [Character] = []

        while index < charactors.count {
            if charactors[index].isNewline {
                if untilBeforeNewLine {
                    return String(result)
                } else {
                    result.append(charactors[index])
                    index += 1
                    continue
                }
            }

            if charactors[index].isWhitespace {
                result.append(charactors[index])
                index += 1
                continue
            }

            if index + 1 < charactors.count, String(charactors[index...index+1]) == "//" {
                result.append(contentsOf: charactors[index...index+1])
                index += 2

                while index < charactors.count && !charactors[index].isNewline {
                    result.append(charactors[index])
                    index += 1
                }

                if !untilBeforeNewLine {
                    result.append(charactors[index])
                    index += 1
                }
                continue
            }

            if index + 1 < charactors.count, String(charactors[index...index+1]) == "/*" {
                result.append(contentsOf: charactors[index...index+1])
                index += 2

                while (index + 1 < charactors.count && String(charactors[index...index+1]) != "*/") {
                    result.append(charactors[index])
                    index += 1
                }

                result.append(contentsOf: charactors[index...index+1])
                index += 2
                continue
            }

            break
        }

        return String(result)
    }

    // 文字数が多い物からチェックしないといけない
    // 例: <= の時に<を先にチェックすると<, =の2つのトークンになってしまう
    private let reservedKinds = TokenKind.ReservedKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }
    private let keywordKinds = TokenKind.KeywordKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }
    private let typeKinds = TokenKind.TypeKind.allCases.sorted { $0.rawValue.count > $1.rawValue.count }

    private func extractTokenKind() throws -> (TokenKind, Int) {
        if charactors[index].isNumber {
            return extractNumber()
        }

        if charactors[index] == "\"" {
            return extractString()
        }

        for reservedKind in reservedKinds {
            let reservedString = reservedKind.rawValue
            if index + (reservedString.count - 1) < charactors.count,
               String(charactors[index..<index+reservedString.count]) == reservedString {
                let reserved = (TokenKind.reserved(reservedKind), index)
                index += reservedString.count

                return reserved
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

                let keyword = (TokenKind.keyword(keywordKind), index)
                index += keywordString.count

                return keyword
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

                let type = (TokenKind.type(typeKind), index)
                index += typeString.count

                return type
            }
        }

        if charactors[index].isIdentifierCharactor {
            return extractIdentifier()
        }

        throw TokenizeError.unknownToken(index: index)
    }
}

private extension Character {
    var isIdentifierCharactor: Bool {
        ("a" <= self && self <= "z") || ("A" <= self && self <= "Z") || ("0" <= self && self <= "9") || self == "_"
    }
}
