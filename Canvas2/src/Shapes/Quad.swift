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
        
        // Compute the quad vertices ABCD.
        let size = self.brush.size / 2
        let color = self.brush.color

        let perpendicular = self.start.perpendicular(other: self.end).normalize()
        let A = self.start + (perpendicular * CGSize(width: size, height: size))
        let B = self.start - (perpendicular * CGSize(width: size, height: size))
        let C = self.end + (perpendicular * CGSize(width: size, height: size))
        let D = self.end - (perpendicular * CGSize(width: size, height: size))

        // Place the quad points into the vertices array to form two triangles.
        self.vertices = [
            // Triangle 1
            Vertex(position: A, color: color),
            Vertex(position: B, color: color),
            Vertex(position: C, color: color),

            // Triangle 2
            Vertex(position: B, color: color),
            Vertex(position: C, color: color),
            Vertex(position: D, color: color),
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
