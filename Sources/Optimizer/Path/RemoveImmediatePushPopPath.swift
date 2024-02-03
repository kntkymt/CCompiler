import Generator

/// 同一レジスタにおいてpushしてすぐpopする無駄な処理を省く
///
/// 該当例:
/// push x0
/// pop x0
///
/// 該当しない例
/// push x1
/// pop x0
///
/// push x0
/// add x0, x1, x0
/// mov x1, x0
/// pop x0
struct RemoveImmediatePushPopPath: OptimizePath {

    func optimize(instructions: [AsmRepresent.Instruction]) -> [AsmRepresent.Instruction] {
        var result: [AsmRepresent.Instruction] = []

        var index = 0
        while index < instructions.count {
            if case .push(let pushRegister) = instructions[index],
               index + 1 < instructions.count,
               case .pop(let popRegister) = instructions[index + 1],
               pushRegister == popRegister {
                index += 2
            } else {
                result.append(instructions[index])
                index += 1
            }
        }

        return result
    }
}
