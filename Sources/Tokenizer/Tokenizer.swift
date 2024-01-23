public enum TokenizeError: Error, Equatable {
    case unknownToken(location: SourceLocation)
}

public class Tokenizer {

    // MARK: - Property

    private let charactors: [Character]

    private var currentSourceLocation = SourceLocation(line: 1, column: 1)
    private var index = 0 {
        willSet {
            if charactors[index].isNewline {
                currentSourceLocation.line += 1
                currentSourceLocation.column = 1
            } else {
                currentSourceLocation.column += (newValue - index)
            }
        }
    }

    // MARK: - Initializer

    public init(source: String) {
        self.charactors = [Character](source)
    }

    // MARK: - Public

    public func tokenize() throws -> [Token] {
        var tokens: [Token] = []

        while index < charactors.count {
            let leadingTrivia = extractTrivia(untilBeforeNewLine: false)

            // sourceLocationにtriviaは含まない
            let startLocation = currentSourceLocation
            let kind = try extractTokenKind()
            let endLocation = currentSourceLocation

            let trailingTrivia = extractTrivia(untilBeforeNewLine: true)

            let token = Token(
                kind: kind,
                leadingTrivia: leadingTrivia,
                trailingTrivia: trailingTrivia,
                sourceRange: SourceRange(start: startLocation, end: endLocation)
            )
            tokens.append(token)
        }

        if let lastToken = tokens.last, lastToken.kind != .endOfFile {
            tokens.append(Token(kind: .endOfFile, sourceRange: SourceRange(start: currentSourceLocation, end: currentSourceLocation)))
        }

        return tokens
    }

    // MARK: - Private

    private func extractNumber() -> TokenKind {
        var string = ""

        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isNumber {
                string += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return .number(string)
    }

    private func extractString() -> TokenKind {
        var content = ""

        // 開始の"
        index += 1

        while index < charactors.count {
            let nextToken = charactors[index]

            if nextToken == "\"" {
                index += 1
                break
            } else {
                content += String(nextToken)
                index += 1
            }
        }

        return .stringLiteral(content)
    }

    private func extractIdentifier() -> TokenKind {
        var string = ""

        while index < charactors.count {
            let nextToken = charactors[index]
            if nextToken.isIdentifierCharactor {
                string += String(nextToken)
                index += 1
            } else {
                break
            }
        }

        return .identifier(string)
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

                if index < charactors.count, !untilBeforeNewLine {
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

    private func extractTokenKind() throws -> TokenKind {
        if index >= charactors.count {
            return .endOfFile
        }

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
                let reserved = TokenKind.reserved(reservedKind)
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

                let keyword = TokenKind.keyword(keywordKind)
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

                let type = TokenKind.type(typeKind)
                index += typeString.count

                return type
            }
        }

        if charactors[index].isIdentifierCharactor {
            return extractIdentifier()
        }

        throw TokenizeError.unknownToken(location: currentSourceLocation)
    }
}

private extension Character {
    var isIdentifierCharactor: Bool {
        ("a" <= self && self <= "z") || ("A" <= self && self <= "Z") || ("0" <= self && self <= "9") || self == "_"
    }
}
