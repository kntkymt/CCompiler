public func compile(_ source: String) -> String {
    var compiled = ".globl _main\n"

    compiled += "_main:\n"

    let charactors = [Character](source)
    var index = 0

    func extractInt() -> String {
        var token = ""
        while index < charactors.count {
            let nextToken = String(charactors[index])
            if Int(nextToken, radix: 10) != nil {
                token += nextToken
                index += 1
            } else {
                break
            }
        }

        return token
    }

    // 最初は数字
    let firstInt = extractInt()
    compiled += "    mov w0, #\(firstInt)\n"

    while index < charactors.count {
        switch charactors[index] {
        case "+":
            index += 1

            let int = extractInt()
            compiled += "    add w0, w0, #\(int)\n"

        case "-":
            index += 1

            let int = extractInt()
            compiled += "    sub w0, w0, #\(int)\n"

        default:
            fatalError("unexpected syntax")
            break
        }
    }

    compiled += "    ret\n"

    return compiled
}
