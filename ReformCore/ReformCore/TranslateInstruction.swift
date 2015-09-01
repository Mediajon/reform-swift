//
//  TranslateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct TranslateInstruction : Instruction {
    public typealias DistanceType = protocol<RuntimeDistance, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let distance : DistanceType
    
    public init(formId: FormIdentifier, distance: DistanceType) {
        self.formId = formId
        self.distance = distance
    }
    
    public func evaluate<T:Runtime>(runtime: T) {
        guard let form = runtime.get(formId) as? Translatable else {
            runtime.reportError(.UnknownForm)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(.InvalidDistance)
            return
        }
        
        form.translator.translate(runtime, delta: delta)
    }
    
    
    public func getDescription(stringifier: Stringifier) -> String {        let formName = stringifier.labelFor(formId) ?? "???"
        
        return "Move \(formName) \(distance.getDescription(stringifier))"
    }
    
    
    public func analyze<T:Analyzer>(analyzer: T) {
    }
}