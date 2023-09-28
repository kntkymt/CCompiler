
public func compile() -> String {
"""
.globl    _main
_main:
    mov    w0, #42
    ret
"""
}
