//
//  CGContext.swift
//  CorbusierKit
//
//  Created by Олег on 04.02.2018.
//

import CoreGraphics
import CoreCorbusier

public final class CGCRBContext : CRBObject {
    
    public let context: CGContext
    
    public init(context: CGContext) {
        self.context = context
    }
    
    public var state: CRBObjectState {
        return .placed(context)
    }
    
    public func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        guard let name = anchorName.first else {
            return false
        }
        return context.isAnchorSupported(anchorName: name)
    }
    
    public func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        fatalError()
    }
    
}

extension CGContext : CRBAnchorEnvironment {
    
    public var state: CRBObjectState {
        return .placed(self)
    }
    
    private enum Anchor : String {
        case left
    }
    
    public func isAnchorSupported(anchorName: CRBAnchorName) -> Bool {
        return Anchor(rawValue: anchorName.rawValue) != nil
    }
    
    public func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        let anch = Anchor(rawValue: name.rawValue)!
        switch anch {
        case .left:
            return CRBAnchor(point: CRBPoint.init(x: 0, y: CRBFloat(height / 2)),
                             normalizedVector: CRBVector(dx: +1, dy: 0).alreadyNormalized())
        }
    }
    
}
