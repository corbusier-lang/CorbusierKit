//
//  CALayer+Corbusier.swift
//  CorbusierKit
//
//  Created by Олег on 09.04.2018.
//

import QuartzCore
import CoreCorbusier

public final class CACRBContext : CRBObject {
    
    public let canvas: CACRBCanvas
    
    public init(canvas: CACRBCanvas) {
        self.canvas = canvas
    }
    
    public var state: CRBObjectState {
        return .placed(canvas)
    }
    
    public func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        guard let name = anchorName.first else {
            return false
        }
        return canvas.isAnchorSupported(anchorName: name)
    }
    
    public func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        fatalError()
    }
    
}

public final class CACRBCanvas : CRBAnchorEnvironment {
    
    public let layer: CALayer
    
    public init(layer: CALayer) {
        self.layer = layer
    }
    
    private enum Anchor : String {
        case left
    }
    
    public func isAnchorSupported(anchorName: CRBAnchorName) -> Bool {
        return Anchor(rawValue: anchorName.rawValue) != nil
    }
    
    public func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        guard let anch = Anchor(rawValue: name.rawValue) else {
            return nil
        }
        switch anch {
        case .left:
            return CRBAnchor(point: CRBPoint.init(x: 0, y: CRBFloat(layer.bounds.height / 2)),
                             normalizedVector: CRBVector(dx: +1, dy: 0).alreadyNormalized())
        }
    }
    
}

extension CALayer : CRBObject {
    
    public var state: CRBObjectState {
        unowned let layer = self
        return .placed(layer)
    }
    
    public func isAnchorSupported(anchorName: CRBAnchorKeyPath) -> Bool {
        return Rect(rect: .zero).anchor(at: anchorName) != nil
    }
    
    public func place(at point: CRBPoint, fromAnchorWith keyPath: CRBAnchorKeyPath) {
        let path = keyPath.map({ $0.rawValue }).joined(separator: ".")
        switch path {
        case "top.left", "left.top":
            self.anchorPoint = CGPoint(x: 0, y: 1)
        case "top.center", "top":
            self.anchorPoint = CGPoint(x: 0.5, y: 1)
        case "top.right", "right.top":
            self.anchorPoint = CGPoint(x: 1, y: 1)
        case "bottom.left", "left.bottom":
            self.anchorPoint = CGPoint(x: 0, y: 0)
        case "bottom.center", "bottom":
            self.anchorPoint = CGPoint(x: 0.5, y: 0)
        case "bottom.right", "right.bottom":
            self.anchorPoint = CGPoint(x: 1, y: 0)
        case "left":
            self.anchorPoint = CGPoint(x: 0, y: 0.5)
        case "right":
            self.anchorPoint = CGPoint(x: 1, y: 0.5)
        default:
            self.anchorPoint = CGPoint(x: 0, y: 0)
        }
        self.position = CGPoint(x: point.x, y: point.y)
    }
    
}

extension CALayer : CRBAnchorEnvironment {
    
    public func anchor(with name: CRBAnchorName) -> CRBAnchor? {
        let rect = Rect(rect: frame)
        return rect.anchor(with: name)
    }
    
}
