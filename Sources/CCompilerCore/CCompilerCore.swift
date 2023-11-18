import Parser
import Generator
import Tokenizer

public enum CompileError: Error, Equatable {
    case invalidSyntax(index: Int)
    case invalidToken(index: Int)
    case unknown
}

public func compile(_ source: String) throws -> String {
    var compiled = ".globl _main\n"
    compiled += "_main:\n"

    let tokens = try {
        do {
            return try tokenize(source: source)
        } catch let error as TokenizeError {
            switch error {
            case .unknownToken(let index):
                throw CompileError.invalidToken(index: index)
            }

        } catch {
            throw CompileError.unknown
        }
    }()
    let nodes = try {
        do {
            return try Parser(tokens: tokens).parse()
        } catch let error as ParseError {
            switch error {
            case .invalidSyntax(let index):
                throw CompileError.invalidSyntax(index: index)
            }

        } catch {
            throw CompileError.unknown
        }
    }()

    // プロローグ
    // push 古いBR, 呼び出し元LR
    compiled += "    stp x29, x30, [sp, #-16]!\n"
    // 今のスタックのトップをBRに（新しい関数フレームを宣言）
    compiled += "    mov x29, sp\n"

    // FIXME: ここの確保数を実際の数にしたいが、Parserで調べるのかGenで調べるのかわからないので保留
    // 26個分の変数を確保
    compiled += "    sub sp, sp, #208\n"

    for node in nodes {
        do {
            compiled += try generate(node: node)

            // 次のstmtに行く前に今のstmtの最終結果を消す
            compiled += "    ldr w0, [sp]\n"
            compiled += "    add sp, sp, #16\n"
        } catch let error as GenerateError {
            switch error {
            case .invalidSyntax(let index):
                throw CompileError.invalidSyntax(index: index)
            }
        } catch {
            throw CompileError.unknown
        }
    }

    return compiled
}
