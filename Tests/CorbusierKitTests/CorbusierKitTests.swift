import XCTest
@testable import CorbusierKit

import CorbusierLang
import CoreCorbusier

class CorbusierKitTests: XCTestCase {
    
    func makeContext() -> CGCRBContext {
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
        return cgcrbcontext
    }
    
    func saveImage(from context: CGContext, imageName: String) {
        let bitmap = NSBitmapImageRep.init(cgImage: context.makeImage()!)
        guard let jpegData = bitmap
            .representation(using: .jpeg, properties: [:]) else {
                print("Fail")
                exit(1)
        }
        let url = URL.init(fileURLWithPath: "/Users/oleg/Pictures/\(imageName).jpg")
        FileManager.default.createFile(atPath: url.path, contents: jpegData, attributes: nil)
    }
    
    func testExample() throws {
        let cgcrbcontext = makeContext()
        let context = cgcrbcontext.context
        
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
        
        let code = """
place area1.left.top < 100 > canvas.left
place area2.bottom.left < 50 > area1.top.left

place area3.left < 50 > area2.right

let bottom = area3.bottom
place area4.top.right < 50 > bottom.right
place area5.top.left < 50 > bottom.left
"""
        print(code)
        let program = Corbusier(multiline: code, context: corbusier)
        try program.run()
        
        for rect in objcts.flatMap({ try? $0.placed() as! Rect }) {
            context.fill(rect.rect)
        }
        
        saveImage(from: context, imageName: "CORBUSIER")

    }
    
    func testVisual() throws {
        let cgcrbcontext = makeContext()
        let context = cgcrbcontext.context
        let squareSize = CGSize(width: 90, height: 90)
        var squares: [CGArea] = []
        for _ in 1 ... 9 {
            let sq = CGArea(size: squareSize)
            squares.append(sq)
        }
        
        var corbusier = CRBContext()
        corbusier.instances = [
            crbname("canvas"): cgcrbcontext,
            crbname("s1"): squares[0],
            crbname("s2"): squares[1],
            crbname("s3"): squares[2],
            crbname("s4"): squares[3],
            crbname("s5"): squares[4],
            crbname("s6"): squares[5],
            crbname("s7"): squares[6],
            crbname("s8"): squares[7],
            crbname("s9"): squares[8],
        ]
        
        let code = """
place s1.left < 400 > canvas.left
place s2.left.top < 50 > s1.right.top
place s3.bottom < 50 > s2.top
place s4.right.bottom < 50 > s3.left.bottom
place s5.top.right < 50 > s4.left.top
place s6.top < 50 > s5.bottom.center
place s7.right.top < 50 > s6.bottom.right
place s8.left.bottom < 50 > s7.right.bottom
place s9.left < 50 > s8.right
"""
        
        let program = Corbusier(multiline: code, context: corbusier)
        try program.run()
        
        var alpha = 1.0 as CGFloat
        for rect in squares.flatMap({ try? $0.placed() as! Rect }) {
            let original = NSColor.white.withAlphaComponent(alpha).cgColor
            alpha -= 0.07
            context.setFillColor(original)
            context.fill(rect.rect)
        }
        
        saveImage(from: context, imageName: "VISUALCRB")

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

