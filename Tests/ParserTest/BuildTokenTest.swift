import XCTest
import Tokenizer

func buildTokens(kinds: [TokenKind]) -> [Token] {
    var column = 1
    var tokens: [Token] = []

    for kind in kinds {
        let start = SourceLocation(line: 1, column: column)
        column += kind.text.count
        let end = SourceLocation(line: 1, column: column)

        let token = Token(
            kind: kind,
            sourceRange: SourceRange(start: start, end: end)
        )
        tokens.append(token)
    }

    return tokens
}

final class BuildTokenTest: XCTestCase {

    func testBuildTokens1() {
        let kinds: [TokenKind] = [
            .identifier("a"),
            .reserved(.assign),
            .number("2"),
            .reserved(.semicolon)
        ]
        let tokens = buildTokens(kinds: kinds)

        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: kinds[0],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 1),
                        end: SourceLocation(line: 1, column: 2)
                    )
                ),
                Token(
                    kind: kinds[1],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 2),
                        end: SourceLocation(line: 1, column: 3)
                    )
                ),
                Token(
                    kind: kinds[2],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 3),
                        end: SourceLocation(line: 1, column: 4)
                    )
                ),
                Token(
                    kind: kinds[3],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 4),
                        end: SourceLocation(line: 1, column: 5)
                    )
                ),
            ]
        )
    }

    func testBuildTokens2() {
        let kinds: [TokenKind] = [
            .type(.int),
            .identifier("main"),
            .reserved(.parenthesisLeft),
            .reserved(.parenthesisRight),
            .reserved(.braceLeft),
            .number("1"),
            .reserved(.semicolon),
            .number("2"),
            .reserved(.semicolon),
            .reserved(.braceRight)
        ]
        let tokens = buildTokens(kinds: kinds)

        XCTAssertEqual(
            tokens,
            [
                Token(
                    kind: kinds[0],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 1),
                        end: SourceLocation(line: 1, column: 4)
                    )
                ),
                Token(
                    kind: kinds[1],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 4),
                        end: SourceLocation(line: 1, column: 8)
                    )
                ),
                Token(
                    kind: kinds[2],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 8),
                        end: SourceLocation(line: 1, column: 9)
                    )
                ),
                Token(
                    kind: kinds[3],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 9),
                        end: SourceLocation(line: 1, column: 10)
                    )
                ),
                Token(
                    kind: kinds[4],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 10),
                        end: SourceLocation(line: 1, column: 11)
                    )
                ),
                Token(
                    kind: kinds[5],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 11),
                        end: SourceLocation(line: 1, column: 12)
                    )
                ),
                Token(
                    kind: kinds[6],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 12),
                        end: SourceLocation(line: 1, column: 13)
                    )
                ),
                Token(
                    kind: kinds[7],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 13),
                        end: SourceLocation(line: 1, column: 14)
                    )
                ),
                Token(
                    kind: kinds[8],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 14),
                        end: SourceLocation(line: 1, column: 15)
                    )
                ),
                Token(
                    kind: kinds[9],
                    sourceRange: SourceRange(
                        start: SourceLocation(line: 1, column: 15),
                        end: SourceLocation(line: 1, column: 16)
                    )
                ),
            ]
        )
    }
}
