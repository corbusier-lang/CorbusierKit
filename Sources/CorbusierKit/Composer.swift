//
//  Composer.swift
//  CorbusierKit
//
//  Created by Олег on 23.06.2018.
//

import Foundation
import CoreCorbusier
import CorbusierLang
import AppKit

public func text(_ string: String) -> NSView {
    let field = NSTextField(labelWithString: string)
    field.wantsLayer = true
    return field
}

extension NSImage {
    
    var cg: CGImage {
        var rect = CGRect(origin: .zero, size: size)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
    }
    
}

public func imageView(from image: NSImage) -> NSView {
    let view = NSView.init(frame: CGRect.init(origin: .zero, size: image.size))
    view.wantsLayer = true
    view.layer!.contents = image.cg
    return view
}

public let context = Context()

@discardableResult
public func corbusier(_ code: String) throws -> CRBContext {
    return try corbusier(context: context.context, code: code)
}

internal func resize_layer(_ layer: CALayer, comp: CGFloat) {
    layer.transform = CATransform3DScale(layer.transform, comp, comp, 1)
}

let res = CRBExternalFunctionInstance { (instances) -> CRBInstance in
    let layer = instances[0] as! CALayer
    let comp = instances[1] as! CRBNumberInstance
    resize_layer(layer, comp: comp.value)
    return VoidInstance.shared
}

public class Context {
    
    internal var context: CRBContext
    
    public var canvas: NSView?
    
    internal init() {
        self.context = CRBContext(instances: [:])
        self.context.currentScope.instances[crbname("scale")] = res
    }
    
    public func setCanvas(_ canvas: NSImage) {
        let canvasView = imageView(from: canvas)
        setCanvas(canvasView)
    }
    
    public func setCanvas(_ canvasView: NSView) {
        self.canvas = canvasView
        unowned let layer = canvasView.layer!
        let crbcanvas = CACRBCanvas(layer: layer)
        let contextCanvas = CACRBContext(canvas: crbcanvas)
        context.currentScope.instances[crbname("canvas")] = contextCanvas
    }
        
    public func set(_ varName: String, _ newValue: NSImage) {
        self.set(varName, imageView(from: newValue))
    }
    
    public func set(_ varName: String, _ newValue: NSView) {
        canvas!.addSubview(newValue)
        unowned let layer = newValue.layer!
        context.currentScope.instances[crbname(varName)] = layer
    }
    
    public func set(_ varName: String, _ newValue: CGFloat) {
        context.currentScope.instances[crbname(varName)] = CRBNumberInstance(newValue)
    }
    
    public func set(_ varName: String, _ newValue: Bool) {
        context.currentScope.instances[crbname(varName)] = CRBBoolInstance(newValue)
    }
    
}

