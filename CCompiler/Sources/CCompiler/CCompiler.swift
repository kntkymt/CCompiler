
public func compile(int: Int) -> String {
"""
.globl    _main
_main:
    mov    w0, #\(int)
    ret
"""
}
