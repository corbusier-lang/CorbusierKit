import XCTest
@testable import CorbusierKit

import CorbusierLang
import CoreCorbusier

class CorbusierKitTests: XCTestCase {
    
    func testExample() throws {
        let context = CGContext.init(data: nil,
                                     width: 1000,
                                     height: 500,
                                     bitsPerComponent: 8,
                                     bytesPerRow: 0,
                                     space: CGColorSpace.init(name: CGColorSpace.sRGB)!,
                                     bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect.init(x: 0, y: 0, width: 1000, height: 500))
        
        context.setFillColor(NSColor.white.cgColor)
        let cgcrbcontext = CGCRBContext(context: context)
        
        let size = CGSize.init(width: 200, height: 100)
        let area1 = CGArea(size: size)
        let area2 = CGArea(size: size)
        let area3 = CGArea(size: size)
        let area4 = CGArea(size: CGSize(width: 90, height: 100))
        let area5 = CGArea(size: CGSize(width: 90, height: 100))
        
        let objcts = [area1, area2, area3, area4, area5]
        
        var corbusier = CRBContext()
        corbusier.instances = [
            crbname("canvas") : cgcrbcontext,
            crbname("area1") : area1,
            crbname("area2") : area2,
            crbname("area3") : area3,
            crbname("area4") : area4,
            crbname("area5") : area5,
        ]
        
        try corbusier.run(line: "place area1.left.top < 100 > canvas.left")
        try corbusier.run(line: "place area2.bottom.left < 50 > area1.top.left")
        try corbusier.run(line: "place area3.left < 50 > area2.right")
        try corbusier.run(line: "place area4.top.right < 50 > area3.bottom.right")
        try corbusier.run(line: "place area5.top.left < 50 > area3.bottom.left")
        
        for rect in objcts.flatMap({ try? $0.placed() as! Rect }) {
            context.fill(rect.rect)
        }
        
        let bitmap = NSBitmapImageRep.init(cgImage: context.makeImage()!)
        guard let jpegData = bitmap
            .representation(using: .jpeg, properties: [:]) else {
                print("Fail")
                exit(1)
        }
        let url = URL.init(fileURLWithPath: "/Users/oleg/Pictures/Corbusier.jpg")
        FileManager.default.createFile(atPath: url.path, contents: jpegData, attributes: nil)

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

extension CRBContext {
    
    mutating func run(line: String) throws {
        try corbusierRun(line: line, in: &self)
    }
    
}
