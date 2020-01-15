//
//  Quad.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import UIKit

struct Quad {
    
    // MARK: Variables
    
    var vertices: [Vertex]
    
    var start: CGPoint
    
    var end: CGPoint
    
    var brush: Brush
    
    
    
    
    
    // MARK: Initialization
    
    init(brush: Brush) {
        self.vertices = []
        self.start = CGPoint()
        self.end = CGPoint()
        self.brush = brush
//        self.vertices = [
//            Vertex(position: CGPoint(x: -0.5, y: -0.5), color: .black),
//            Vertex(position: CGPoint(x: -0.5, y: 0), color: .black),
//            Vertex(position: CGPoint(x: 0.5, y: -0.5), color: .black),
//            Vertex(position: CGPoint(x: 0.5, y: 0), color: .black),
//        ]
    }
    
    init(start: CGPoint, brush: Brush) {
        self.vertices = []
        self.start = start
        self.end = CGPoint()
        self.brush = brush
//        self.vertices = [
//            Vertex(position: start, color: .blue),
//            Vertex(position: CGPoint(x: start.x - 0.05, y: start.y - 0.05), color: .blue),
//            Vertex(position: CGPoint(x: start.x + 0.05, y: start.y), color: .blue),
//            Vertex(position: CGPoint(x: start.x, y: start.y - 0.05), color: .blue),
//        ]
    }
    
    
    
    // MARK: Functions
    
    /** Sets the ending position of this quad and promptly computes the rectangular shape
     needed to display it on screen. It really just computes two triangles at the end of the day. */
    mutating func end(at: CGPoint) {
        self.end = at
        
        // Compute the quad vertices and place them in the array.
        let size = self.brush.size
        let color = self.brush.color
        let bottomLeft = CGPoint(x: self.start.x - size, y: self.start.y + size)
        let topLeft = CGPoint(x: self.end.x - size, y: self.end.y + size)
        
        // TODO: FIgure out how to flip the computed quad when the start point
        // has a higher x-value than the end point.
        
        // Set the vertices to form two triangles.
        self.vertices = [
            // Triangle 1
            Vertex(position: start, color: color),
            Vertex(position: bottomLeft, color: color),
            Vertex(position: end, color: color),
            
            // Triangle 2
            Vertex(position: end, color: color),
            Vertex(position: topLeft, color: color),
            Vertex(position: bottomLeft, color: color),
        ]
    }
    
    
    /** Renders this quad onto the screen using the given encoder. */
    func render(encoder: MTLRenderCommandEncoder) {
        guard let buffer = dev.makeBuffer(
            bytes: self.vertices,
            length: self.vertices.count * MemoryLayout<Vertex>.stride,
            options: []) else { return }
        
        let vertCount = buffer.length / MemoryLayout<Vertex>.stride
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertCount)
    }
}
