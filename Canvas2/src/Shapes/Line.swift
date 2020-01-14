//
//  Line.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/13/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/** A straight line that goes from a start point to an end point. */
public struct Line {
    
    // MARK: - Internals
    
    internal var points: [CGPoint]
    
    internal var brush: Brush
    
    
    
    init(brush: Brush) {
        self.points = []
        self.brush = brush
    }
    
    /** Adds a new point onto the line. */
    public mutating func add(point p: CGPoint) {
        // Add the location information.
        points.append(p)
    }
    
    
    /** Handles drawing this line using a rendering encoder. */
    public func render(encoder enc: MTLRenderCommandEncoder) {
        // Construct the buffer array.
        var bufArr: [Float] = []
        for point in self.points {
            bufArr.append(Float(point.x))
            bufArr.append(Float(point.y))
            bufArr.append(0)
            bufArr.append(1)
            bufArr.append(self.brush.size)
            let rgba = self.brush.color.rgba
            let toFloats = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map({ a -> Float in
                return Float(a)
            })
            bufArr.append(contentsOf: toFloats)
        }
        
        // Make the buffer.
        guard let dev = dev else { return }
        let dataLength = bufArr.count * MemoryLayout.size(ofValue: bufArr[0])
        
        let options = MTLResourceOptions(arrayLiteral: [])
        guard let buffer = dev.makeBuffer(
            bytes: bufArr,
            length: dataLength,
            options: options
        ) else { return }
    
        // Use the encoder to draw line strips between the points.
        enc.setVertexBuffer(buffer, offset: 0, index: 0)
        enc.drawPrimitives(type: .point, vertexStart: 0, vertexCount: bufArr.count)
    }
}
