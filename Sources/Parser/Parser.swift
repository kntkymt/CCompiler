import Tokenizer

public enum ParseError: Error, Equatable {
    case invalidSyntax(location: SourceLocation)
}

public final class Parser {

    // MARK: - Property

    var index = 0
    var tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Public

    public func parse() throws -> SourceFileSyntax {
        try program()
    }

    // MARK: - Syntax

    // program = (functionDecl | variableDecl)*
    func program() throws -> SourceFileSyntax {
        var statements: [BlockItemSyntax] = []

        while !at(.endOfFile) {

            let type = try type()
            let identifier = try consume(.identifier)

            // functionDecl = type ident "(" functionParameters? ")" block
            if let parenthesisLeft = consume(if: .reserved(.parenthesisLeft)) {
                var parameters: [FunctionParameterSyntax] = []
                if at(.type) {
                    parameters = try functionParameters()
                }

                let parenthesisRight = try consume(.reserved(.parenthesisRight))

                let function = FunctionDeclSyntax(
                    returnType: type,
                    functionName: identifier,
                    parenthesisLeft: parenthesisLeft,
                    parameters: parameters,
                    parenthesisRight: parenthesisRight,
                    block: try block()
                )
                statements.append(BlockItemSyntax(item: function))
            } else {
                let variable = try variableDecl(variableType: type, identifier: identifier)
                statements.append(BlockItemSyntax(item: variable, semicolon: try consume(.reserved(.semicolon))))
            }
        }

        let endOfFile = try consume(.endOfFile)
        return SourceFileSyntax(statements: statements, endOfFile: endOfFile)
    }

    // functionParameters = functionParameter+
    func functionParameters() throws -> [FunctionParameterSyntax] {
        var results: [FunctionParameterSyntax] = []

        repeat {
            results.append(try functionParameter())
        } while !at(.reserved(.parenthesisRight))

        return results
    }

    // functionParameter = type identifier ","?
    func functionParameter() throws -> FunctionParameterSyntax {
        var type = try type()
        let identifier = try consume(.identifier)

        if at(.reserved(.squareLeft)) {
            type = ArrayTypeSyntax(
                elementType: type,
                squareLeft: try consume(.reserved(.squareLeft)),
                arraySize: try consume(.integerLiteral),
                squareRight: try consume(.reserved(.squareRight))
            )
        }

        return FunctionParameterSyntax(
            type: type,
            identifier: identifier,
            comma: consume(if: .reserved(.comma))
        )
    }

    // stmt    = expr ";"
    //         | block
    //         | variableDecl
    //         | "if" "(" expr ")" stmt ("else" stmt)?
    //         | "while" "(" expr ")" stmt
    //         | "for" "(" expr? ";" expr? ";" expr? ")" stmt
    //         | "return" expr ";"
    func stmt() throws -> BlockItemSyntax {
        switch tokens[index].kind {
        case .reserved(.braceLeft):
            return BlockItemSyntax(item: try block())

        case .type:
            return BlockItemSyntax(item: try variableDecl(), semicolon: try consume(.reserved(.semicolon)))

        case .keyword(.if):
            let ifToken = try consume(.keyword(.if))

            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))
            let condition = try expr()
            let parenthesisRight = try consume(.reserved(.parenthesisRight))

            let trueStatement = try stmt()

            var elseToken: TokenSyntax?
            var falseStatement: BlockItemSyntax?
            if at(.keyword(.else)) {
                elseToken = try consume(.keyword(.else))
                falseStatement = try stmt()
            }

            let ifStatement = IfStatementSyntax(
                if: ifToken,
                parenthesisLeft: parenthesisLeft,
                condition: condition,
                parenthesisRight: parenthesisRight,
                trueBody: trueStatement,
                else: elseToken,
                falseBody: falseStatement
            )
            return BlockItemSyntax(item: ifStatement)

        case .keyword(.while):
            let token = try consume(.keyword(.while))

            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))
            let condition = try expr()
            let parenthesisRight = try consume(.reserved(.parenthesisRight))

            let whileStatement = WhileStatementSyntax(
                while: token,
                parenthesisLeft: parenthesisLeft,
                condition: condition,
                parenthesisRight: parenthesisRight,
                body: try stmt()
            )
            return BlockItemSyntax(item: whileStatement)

        case .keyword(.for):
            let forToken = try consume(.keyword(.for))
            let parenthesisLeft = try consume(.reserved(.parenthesisLeft))

            var preExpr: (any SyntaxProtocol)?
            let firstSemicolon: TokenSyntax
            if let semicolon = consume(if: .reserved(.semicolon)) {
                firstSemicolon = semicolon
            } else {
                preExpr = try expr()
                firstSemicolon = try consume(.reserved(.semicolon))
            }

            var condition: (any SyntaxProtocol)?
            let secondSemicolon: TokenSyntax
            if let semicolon = consume(if: .reserved(.semicolon)) {
                secondSemicolon = semicolon
            } else {
                condition = try expr()
                secondSemicolon = try consume(.reserved(.semicolon))
            }

            var postExpr: (any SyntaxProtocol)?
            let parenthesisRight: TokenSyntax
            if let paren = consume(if: .reserved(.parenthesisRight)) {
                parenthesisRight = paren
            } else {
                postExpr = try expr()
                parenthesisRight = try consume(.reserved(.parenthesisRight))
            }

            let forStatement = ForStatementSyntax(
                for: forToken,
                parenthesisLeft: parenthesisLeft,
                pre: preExpr,
                firstSemicolon: firstSemicolon,
                condition: condition,
                secondSemicolon: secondSemicolon,
                post: postExpr,
                parenthesisRight: parenthesisRight,
                body: try stmt()
            )
            return BlockItemSyntax(item: forStatement)

        case .keyword(.return):
            let token = try consume(.keyword(.return))
            let left = try expr()

            let returnStatement = ReturnStatementSyntax(return: token, expression: left)
            return BlockItemSyntax(
                item: returnStatement,
                semicolon: try consume(.reserved(.semicolon))
            )

        default:
            return BlockItemSyntax(
                item: try expr(),
                semicolon: try consume(.reserved(.semicolon))
            )
        }
    }

    // block = "{" stmt* "}"
    func block() throws -> BlockStatementSyntax {
        let braceLeft = try consume(.reserved(.braceLeft))

        var items: [BlockItemSyntax] = []
        while !at(.reserved(.braceRight)) {
            items.append(try stmt())
        }

        let braceRight = try consume(.reserved(.braceRight))

        return BlockStatementSyntax(
            braceLeft: braceLeft,
            items: items,
            braceRight: braceRight
        )
    }

    // variableDecl = type identifier ("[" num "]")? ("=" (expr | "{" exprList "}" | stringLiteral)? ";"
    func variableDecl(variableType: (any TypeSyntaxProtocol)? = nil, identifier: TokenSyntax? = nil) throws -> VariableDeclSyntax {
        var type = if let variableType { variableType } else { try type() }
        let identifier = if let identifier { identifier } else { try consume(.identifier) }

        if at(.reserved(.squareLeft)) {
            type = ArrayTypeSyntax(
                elementType: type,
                squareLeft: try consume(.reserved(.squareLeft)),
                arraySize: try consume(.integerLiteral),
                squareRight: try consume(.reserved(.squareRight))
            )
        }

        if let initializer = consume(if: .reserved(.assign)) {
            switch tokens[index].kind {
            case .reserved(.braceLeft):
                return VariableDeclSyntax(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: InitListExprSyntax(
                        braceLeft: try consume(.reserved(.braceLeft)),
                        exprListSyntaxs: try exprList(),
                        braceRight: try consume(.reserved(.braceRight))
                    )
                )

            case .stringLiteral:
                return VariableDeclSyntax(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: StringLiteralSyntax(literal: try consume(.stringLiteral))
                )

            default:
                return VariableDeclSyntax(
                    type: type,
                    identifier: identifier,
                    equal: initializer,
                    initializerExpr: try expr()
                )
            }
        }

        return VariableDeclSyntax(
            type: type,
            identifier: identifier
        )
    }

    // type = typeIdentifier "*"*
    func type() throws -> any TypeSyntaxProtocol {
        var syntax: any TypeSyntaxProtocol = TypeSyntax(type: try consume(.type))

        while let mulToken = consume(if: .reserved(.mul)) {
            syntax = PointerTypeSyntax(referenceType: syntax, pointer: mulToken)
        }

        return syntax
    }

    // expr = assign
    func expr() throws -> any SyntaxProtocol {
        try assign()
    }

    // assign = equality ("=" assign)?
    func assign() throws -> any SyntaxProtocol {
        var syntax = try equality()

        if let assignToken = consume(if: .reserved(.assign)) {
            let rightSyntax = try assign()

            syntax = InfixOperatorExprSyntax(
                left: syntax, 
                operator: assignToken,
                right: rightSyntax
            )
        }

        return syntax
    }

    // equality = relational (("==" | "!=") relational)*
    func equality() throws -> any SyntaxProtocol {
        var syntax = try relational()

        while let equalityToken = consume(if: .reserved(.equal), .reserved(.notEqual)) {
            syntax = InfixOperatorExprSyntax(
                left: syntax,
                operator: equalityToken,
                right: try relational()
            )
        }

        return syntax
    }

    // relational = add (("<" | "<=" | ">" | ">=") add)*
    func relational() throws -> any SyntaxProtocol {
        var syntax = try add()

        while let relationalToken = consume(if: .reserved(.lessThan), .reserved(.lessThanOrEqual), .reserved(.greaterThan), .reserved(.greaterThanOrEqual)) {
            syntax = InfixOperatorExprSyntax(
                left: syntax,
                operator: relationalToken,
                right: try add()
            )
        }

        return syntax
    }

    // add = mul (("+" | "-") mul)*
    func add() throws -> any SyntaxProtocol {
        var syntax = try mul()

        while let addOrSub = consume(if: .reserved(.add), .reserved(.sub)) {
            syntax = InfixOperatorExprSyntax(
                left: syntax,
                operator: addOrSub,
                right: try mul()
            )
        }

        return syntax
    }

    // mul = unary (("*" |"/") unary)*
    func mul() throws -> any SyntaxProtocol {
        var syntax = try unary()

        while let mulOrDivToken = consume(if: .reserved(.mul), .reserved(.div)) {
            syntax = InfixOperatorExprSyntax(
                left: syntax,
                operator: mulOrDivToken,
                right: try unary()
            )
        }

        return syntax
    }

    // unary = | ("+" | "-") primary
    //         | ("sizeof" | "*" | "&") unary
    //         | primary
    func unary() throws -> any SyntaxProtocol {
        if let addOrSub = consume(if: .reserved(.add), .reserved(.sub)) {
            return PrefixOperatorExprSyntax(
                operator: addOrSub,
                expression: try primary()
            )
        } else if let sizeofOrMulOrAnd = consume(if: .keyword(.sizeof), .reserved(.mul), .reserved(.and)) {
            return PrefixOperatorExprSyntax(
                operator: sizeofOrMulOrAnd,
                expression: try unary()
            )
        } else {
            return try primary()
        }
    }

    // primary = num
    //         | stringLiteral
    //         | ident ( ("( exprList? )") | ("[" expr "]") )?
    //         | "(" expr ")"
    func primary() throws -> any SyntaxProtocol {
        switch tokens[index].kind {
        case .reserved(.parenthesisLeft):
            return TupleExprSyntax(
                parenthesisLeft: try consume(.reserved(.parenthesisLeft)),
                expression: try expr(),
                parenthesisRight: try consume(.reserved(.parenthesisRight))
            )

        case .integerLiteral:
            return IntegerLiteralSyntax(literal: try consume(.integerLiteral))

        case .stringLiteral:
            return StringLiteralSyntax(literal: try consume(.stringLiteral))

        case .identifier:
            let identifierToken = try consume(.identifier)

            if let parenthesisLeft = consume(if: .reserved(.parenthesisLeft)) {
                var argments: [ExprListItemSyntax] = []
                if !at(.reserved(.parenthesisRight)) {
                    argments = try exprList()
                }

                let parenthesisRight = try consume(.reserved(.parenthesisRight))

                return FunctionCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: identifierToken),
                    parenthesisLeft: parenthesisLeft,
                    arguments: argments,
                    parenthesisRight: parenthesisRight
                )
            } else if at(.reserved(.squareLeft)) {
                return SubscriptCallExprSyntax(
                    identifier: DeclReferenceSyntax(baseName: identifierToken),
                    squareLeft: try consume(.reserved(.squareLeft)),
                    argument: try expr(),
                    squareRight: try consume(.reserved(.squareRight))
                )
            } else {
                return DeclReferenceSyntax(baseName: identifierToken)
            }

        default:
            throw ParseError.invalidSyntax(location: tokens[index].sourceRange.start)
        }
    }

    // exprList = (expr ","?)+
    func exprList() throws -> [ExprListItemSyntax] {
        var results: [ExprListItemSyntax] = []

        repeat {
            results.append(
                ExprListItemSyntax(
                    expression: try expr(),
                    comma: consume(if: .reserved(.comma))
                )
            )
        } while !(at(.reserved(.parenthesisRight)) || at(.reserved(.braceRight)))

        return results
    }
}
