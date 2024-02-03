import Generator

protocol OptimizePath {
    func optimize(instructions: [AsmRepresent.Instruction]) -> [AsmRepresent.Instruction]
}

public enum AsmOptimizer {

    // MARK: - Property

    private static let paths: [any OptimizePath] = [
        RemoveImmediatePushPopPath()
    ]

    // MARK: - Public

    public static func optimize(instructions: [AsmRepresent.Instruction]) -> [AsmRepresent.Instruction] {
        var result = instructions

        for path in paths {
            result = path.optimize(instructions: result)
        }

        return result
    }
}
