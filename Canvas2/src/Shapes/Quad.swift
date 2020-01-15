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

/** A four-sided shape that gets rendered on the screen as two adjacent triangles. */
struct Quad {
    
    // MARK: Variables

    var brush: Brush

    var vertices: [Vertex]
    
    var start: CGPoint
    
    var end: CGPoint
    
    var c: CGPoint
    
    var d: CGPoint
    
    
    
    // MARK: Initialization
    
    init(brush: Brush) {
        self.vertices = []
        self.start = CGPoint()
        self.end = CGPoint()
        self.c = CGPoint()
        self.d = CGPoint()
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
        self.c = CGPoint()
        self.d = CGPoint()
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
    mutating func end(at: CGPoint, prevA: CGPoint? = nil, prevB: CGPoint? = nil) {
        self.end = at
        
        // Compute the quad vertices ABCD.
        let size = self.brush.size / 2
        let color = self.brush.color

        let perpendicular = self.start.perpendicular(other: self.end).normalize()
        var A = self.start + (perpendicular * size)
        var B = self.start - (perpendicular * size)
        let C = self.end + (perpendicular * size)
        let D = self.end - (perpendicular * size)
        
        // Use the previous quad's points
        if let pA = prevA, let pB = prevB {
            A = pA
            B = pB
        }
        self.c = C
        self.d = D

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
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
    }
}
