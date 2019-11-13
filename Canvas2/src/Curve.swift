//
//  Curve.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/11/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/** Represents a single curve that can be drawn on the canvas. */
public struct Curve {
    
    // INTERNAL
    var points: [Float]
    var buffer: MTLBuffer?
    var thickness: Float
    var color: UIColor
    
    // COMPUTED
    var numPoints: Int {
        return self.points.count
    }
    
    
    
    
    init() {
        self.points = []
        self.buffer = nil
        self.thickness = 1
        self.color = UIColor.black
    }
    
    /** Sets the MTLBuffer to use for rendering this curve onto the screen.  */
    mutating func setBuffer(buffer: MTLBuffer) {
        self.buffer = buffer
    }
    
    /** Adds a new point onto the curve. */
    mutating func add(x: Float, y: Float) {
        // Add the points on the line.
        self.points.append(contentsOf: [x, y, 0, 1])
        
        // Add the color information.
        let rgba = self.color.rgba
        self.points.append(Float(rgba.red))
        self.points.append(Float(rgba.green))
        self.points.append(Float(rgba.blue))
        self.points.append(Float(rgba.alpha))
    }
    
    /** A helper function that takes an MTLRenderEncoder as a paramater and uses it to draw the curve on the screen. */
    public func render(encoder enc: MTLRenderCommandEncoder) {
        guard let buffer = self.buffer else { return }
        
        enc.setVertexBuffer(buffer, offset: 0, index: 0)
        enc.drawPrimitives(type: MTLPrimitiveType.lineStrip, vertexStart: 0, vertexCount: self.numPoints)
    }
}
