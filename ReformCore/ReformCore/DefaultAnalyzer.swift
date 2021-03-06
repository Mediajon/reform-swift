//
//  DefaultAnalyzer.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct InstructionOutlineRow {
    public let node : InstructionNode
    public let label : String
    public let depth : Int
    public let isGroup : Bool
}

final class AnalyzerStringifier : Stringifier {
    private var forms = [FormIdentifier:Form]()
    private let expressionPrinter : ExpressionPrinter

    init(expressionPrinter : ExpressionPrinter) {
        self.expressionPrinter = expressionPrinter
    }

    func labelFor(_ formId: FormIdentifier) -> String? {
        return forms[formId].map{ $0.name }
    }

    func labelFor(_ formId: FormIdentifier, pointId: ExposedPointIdentifier) -> String? {
        return forms[formId].flatMap { $0.getPoints()[pointId].map { $0.getDescription(self) } }
    }

    func labelFor(_ formId: FormIdentifier, anchorId: AnchorIdentifier) -> String? {
        return forms[formId].flatMap{
            ($0 as? Morphable).flatMap {
                $0.getAnchors()[anchorId].map {
                    $0.name
                }
            }
        }
    }

    func stringFor(_ expression: ReformExpression.Expression) -> String? {
        return expressionPrinter.toString(expression)
    }
}

final public class DefaultAnalyzer : Analyzer {
    public private(set) var instructions = [InstructionOutlineRow]()
    public private(set) var instructionsDblBuf = [InstructionOutlineRow]()
    private let nameAllocator : NameAllocator

    private let analyzerStringifier : AnalyzerStringifier
    public var stringifier : Stringifier {
        return analyzerStringifier
    }
    private var depth: Int = 0
    
    public init(expressionPrinter: ExpressionPrinter, nameAllocator : NameAllocator) {
        self.analyzerStringifier = AnalyzerStringifier(expressionPrinter: expressionPrinter)
        self.nameAllocator = nameAllocator
    }
    
    public func analyze(@noescape _ block: () -> ()) {
        analyzerStringifier.forms.removeAll(keepingCapacity: true)
        instructionsDblBuf.removeAll(keepingCapacity: true)
        nameAllocator.reset()
        depth = 0
        block()

        swap(&instructionsDblBuf, &instructions)
    }
    
    public func publish(_ instruction: Analyzable, label: String) {
        guard let node = instruction as? InstructionNode else {
            return
        }
        instructionsDblBuf.append(InstructionOutlineRow(node: node, label: label, depth: depth, isGroup: false))
    }
    
    public func publish(_ instruction: Analyzable, label: String, @noescape block: () -> ()) {
        guard let node = instruction as? InstructionNode else {
            return
        }

        // skip root
        if depth > 0 {
            instructionsDblBuf.append(InstructionOutlineRow(node: node, label: label, depth: depth, isGroup: true))
        }
        defer {
            if depth > 0 {
            instructionsDblBuf.append(InstructionOutlineRow(node: node, label: "", depth: depth, isGroup: true))
            }
        }

        depth += 1

        defer { depth -= 1 }

        block()
    }
    
    public func announceForm(_ form: Form) {
        analyzerStringifier.forms[form.identifier] = form
        nameAllocator.announce(form.name)
    }
    
    public func announceDepencency(_ id: PictureIdentifier) {
    
    }
}
