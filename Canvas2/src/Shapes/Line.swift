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
    
    internal var points: [Float]
    
    internal var canvas: Canvas
    
    
    
    init(canvas: Canvas) {
        self.points = []
        self.canvas = canvas
    }
    
    /** Adds a new point onto the line. */
    public mutating func add(point p: SIMD4<Float>) {
        // Add the location information.
        points.append(contentsOf: [p.x, p.y, p.z, p.w])
        
        // Add the brush size information.
        points.append(self.canvas.currentBrush.size)
        
        // Add the color information.
        let rgba = self.canvas.currentBrush.color.rgba
        let toFloats = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map({ a -> Float in
            return Float(a)
        })
        points.append(contentsOf: toFloats)
    }
    
    
    /** Handles drawing this line using a rendering encoder. */
    public func render(encoder enc: MTLRenderCommandEncoder) {
        // Make the buffer.
        guard let dev = dev else { return }
        let dataLength = points.count * MemoryLayout.size(ofValue: points[0])
        
        let options = MTLResourceOptions(arrayLiteral: [])
        guard let buffer = dev.makeBuffer(
            bytes: points,
            length: dataLength,
            options: options
        ) else { return }
    
        // Use the encoder to draw line strips between the points.
        enc.setVertexBuffer(buffer, offset: 0, index: 0)
        enc.drawPrimitives(type: .point, vertexStart: points.count, vertexCount: points.count)
    }
}
